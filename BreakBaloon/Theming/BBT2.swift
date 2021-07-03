//
//  BBT2.swift
//  BreakBaloon
//
//  Created by Emil on 13/08/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit

class BBT2: AbstractTheme {
    let null: String? = nil
    
    let dir: String
    
    var functions: [String: (String) throws -> String?] = [:]
    var methods: [String: (String, String) throws -> String?] = [:]
    var properties: [String: String?] = [:]
    var localVariables: [String: String?] = [:]
    var constants: [String: String?] = [:]
    var baloons: [(UIImage, UIImage, UIImage, UIImage, UIImage)] = []
    var animationColors: [UIColor?] = []
    
    let completeCode: String
    var line = 0
    
    init(dir: String, code: String) throws {
        self.dir = dir
        completeCode = code.replacingOccurrences(of: "\r", with: "")
        let lines = completeCode.components(separatedBy: "\n")

        // MARK: constants & default properties

        constants["_PLATFORM_OS"] = "iOS"
        constants["_PLATFORM_DEVICE_MODEL"] = UIDevice.current.localizedModel
        constants["_PLATFORM_DEVICE_NAME"] = UIDevice.current.name
        constants["_PLATFORM_VERSION"] = UIDevice.current.systemVersion
        constants["_BREAKBALOON_VERSION"] = "1.0.0"
        constants["_BBTC_VERSION"] = "1.0.0"
        constants["COLOR_BLACK"] = "0"
        constants["COLOR_WHITE"] = "16581375"
        constants["COLOR_RED"] = "16711680"
        constants["COLOR_BLUE"] = "255"
        constants["COLOR_GREEN"] = "65280"
        constants["COLOR_YELLOW"] = "16776960"
        constants["COLOR_ORANGE"] = "16744448"
        constants["COLOR_PINK"] = "16711935"
        constants["COLOR_PURPLE"] = "8388736"
        constants["COLOR_AQUA"] = "65535"
        properties["theme.id"] = null
        properties["theme.name"] = null
        properties["theme.description"] = null
        properties["theme.author"] = null
        properties["theme.version"] = null
        properties["theme.background"] = null
        properties["image.icon"] = null
        properties["image.wicon"] = null
        properties["image.cursor"] = null
        properties["sound.pump"] = null
        properties["sound.wpump"] = null

        // MARK: functions & methods

        functions["print"] = printString
        functions["fileImage"] = fileImage
        functions["unicolor"] = unicolor
        functions["emptyImage"] = emptyImage
        functions["imageByConcat"] = concatImage
        functions["isset_set"] = issetSet
        functions["localized"] = localized
        methods["grayscale"] = grayscale
        methods["toLower"] = toLower
        methods["toUpper"] = toUpper
        methods["toCap"] = toCap
        methods["rotate"] = rotate
        methods["rotate_flip"] = rotateFlip
        methods["replaceColors"] = pixelChange
        methods["darker"] = imageDarker
        methods["brighter"] = imageBrighter
        methods["add"] = add

        // MARK: parse

        var commands: [(Int, String)] = []
        for line in 0 ..< lines.count {
            if !lines[line].hasPrefix("//") {
                for cmd in lines[line].components(separatedBy: "//")[0].components(separatedBy: ";") {
                    commands.append((line, cmd))
                }
            }
        }
        for cmd in commands {
            if line > cmd.0 {
                continue
            }
            line = cmd.0
            do {
                _ = try exec(cmd.1)
            } catch {
                print("\tat line \(line + 1)")
                throw error
            }
        }
    }
    
    func exec(_ cmd: String) throws -> String? {
        return try exec(cmd, properties: &properties)
    }
    
    func exec(_ cmd: String, properties: inout [String: String?]) throws -> String? {
        if cmd.trimmingCharacters(in: CharacterSet.whitespaces).hasPrefix("image.baloons"), cmd.contains("=") {
            let vals = cmd.components(separatedBy: "=")
            if vals[1].trimmingCharacters(in: CharacterSet.whitespaces) == "[" {
                try parseBaloonBlock()
            } else {
                print("Invalid baloons declaration syntax")
                throw ExecErrors.assignUndeclaredVariableError
            }
        } else if cmd.contains("+=") {
            let varAndValToConcat = cmd.components(separatedBy: "+=")
            let variable = varAndValToConcat[0].trimmingCharacters(in: CharacterSet.whitespaces)
            if (properties[variable] != nil && properties[variable]! != nil) || (self.properties[variable] != nil && self.properties[variable]! != nil) {
                try set(variable, value: properties[variable]!! + execIfNeeds(varAndValToConcat[1].trimmingCharacters(in: CharacterSet.whitespaces))!)
                return properties[variable]!
            }
            print("Tried to concat a value to the undeclared variable \(variable)")
            throw ExecErrors.assignUndeclaredVariableError
        } else if cmd.contains("=") {
            // Assignation
            let vals = cmd.components(separatedBy: "=")
            let property = NSString(string: vals[0]).trimmingCharacters(in: CharacterSet.whitespaces)
            if property.hasPrefix("val ") {
                constants[String(property[property.index(property.startIndex, offsetBy: 4)...])] = try value(vals)
            } else if property.hasPrefix("var ") {
                properties[String(property[property.index(property.startIndex, offsetBy: 4)...])] = try value(vals)
            } else if properties[property] != nil || self.properties[property] != nil {
                try set(property, value: value(vals)!)
            } else {
                print("Tried to assign a value to the undeclared variable \(property)")
                throw ExecErrors.assignUndeclaredVariableError
            }
        } else if cmd.contains("(") {
            var components = cmd.components(separatedBy: "(")
            let methodName = components[0].trimmingCharacters(in: CharacterSet.whitespaces)
            if functions[methodName] != nil {
                components.removeFirst()
                var arg = components.joined(separator: "(")
                let range = arg.range(of: ")", options: .backwards)
                if range == nil {
                    print("Missing closing bracket ')'")
                    throw ExecErrors.syntaxError
                }
                arg.removeSubrange(range!.lowerBound ..< arg.endIndex)
                return try functions[methodName]!(arg)
            }
            let lastDotRange = methodName.range(of: ".", options: .backwards)!
            let lastDot = lastDotRange.lowerBound
            let lastDotString = methodName[lastDotRange]
            if methods[String(methodName[lastDotString.index(after: lastDot) ..< methodName.endIndex])] != nil, valueExists(String(methodName[methodName.startIndex ..< lastDot]), properties: properties) {
                components.removeFirst()
                var arg = components.joined(separator: "(")
                let range = arg.range(of: ")", options: .backwards)
                if range == nil {
                    print("Missing closing bracket ')'")
                    throw ExecErrors.syntaxError
                }
                arg.removeSubrange(range!.lowerBound ..< arg.endIndex)
                return try methods[String(methodName[lastDotString.index(after: lastDot) ..< methodName.endIndex])]!(String(methodName[methodName.startIndex ..< lastDot]), arg)
            }
            print("Couldn't resolve \(methodName)")
            throw ExecErrors.callUndeclaredMethodError
        }
        return null
    }
    
    func valueExists(_ name: String, properties: [String: String?]) -> Bool {
        return properties[name] != nil || constants[name] != nil || self.properties[name] != nil
    }
    
    func set(_ name: String, value: String) throws {
        if localVariables[name] != nil {
            localVariables[name] = value
        } else if properties[name] != nil {
            properties[name] = value
        } else if constants[name] != nil {
            print("Tried to edit a constant value")
            throw ExecErrors.editConstantError
        }
    }
    
    func get(_ name: String) -> String? {
        if localVariables[name] != nil {
            return localVariables[name]!
        } else if constants[name] != nil {
            return constants[name]!
        } else if properties[name] != nil {
            return properties[name]!
        }
        return nil
    }
    
    func value(_ vals: [String]) throws -> String? {
        return vals.count == 1 ? null : try execIfNeeds(NSString(string: vals[1]).trimmingCharacters(in: CharacterSet.whitespaces))
    }
    
    func execIfNeeds(_ cmd: String) throws -> String? {
        if cmd.lowercased() == "null" {
            return null
        } else if localVariables[cmd] != nil {
            return localVariables[cmd]!
        } else if constants[cmd] != nil {
            return constants[cmd]!
        } else if properties[cmd] != nil {
            return properties[cmd]!
        } else if cmd.hasPrefix("\"") && cmd.hasSuffix("\"") && cmd.components(separatedBy: "\"").count == 3 {
            return cmd.replacingOccurrences(of: "\\\\", with: "\\").replacingOccurrences(of: "\\n", with: "\n").replacingOccurrences(of: "\\t", with: "\t").replacingOccurrences(of: "\\r", with: "\r").replacingOccurrences(of: "\"", with: "")
        } else if cmd.contains("(") || cmd.contains("=") {
            return try exec(cmd)
        } else if cmd.contains("++") {
            var valsToConcat = cmd.components(separatedBy: "++")
            for i in 0 ..< valsToConcat.count {
                valsToConcat[i] = try execIfNeeds(valsToConcat[i].trimmingCharacters(in: CharacterSet.whitespaces))!
            }
            return valsToConcat.joined(separator: " ")
        } else if cmd.contains("+") {
            var valsToConcat = cmd.components(separatedBy: "+")
            for i in 0 ..< valsToConcat.count {
                valsToConcat[i] = try execIfNeeds(valsToConcat[i].trimmingCharacters(in: CharacterSet.whitespaces))!
            }
            return valsToConcat.joined(separator: "")
        }
        return cmd
    }
    
    func printString(_ stringLiteral: String) throws -> String? {
        print("[BBTC] [\(themeID())] \(try execIfNeeds(stringLiteral)!)")
        return nil
    }
    
    func parseBaloonBlock() throws {
        var inBaloonBlock = -1
        var cmps = completeCode.components(separatedBy: "\n")
        cmps.removeSubrange(0 ..< line)
        for line in cmps {
            if inBaloonBlock != -1 {
                if line.contains("}") {
                    baloons.insert((getImage("closed"), getImage("opened"), getImage("openedGood", default: "opened"), getImage("closedFake"), getImage("openedFake")), at: inBaloonBlock)
                    if localVariables["extension.animationColor"]! != nil {
                        animationColors.insert(UIColor(rgbValue: UInt(localVariables["extension.animationColor"]!!)!), at: inBaloonBlock)
                    }
                    localVariables.removeAll()
                    inBaloonBlock = -1
                } else if line.contains("]") {
                    print("Early baloon block array end")
                    throw ExecErrors.syntaxError
                } else {
                    _ = try exec(line.components(separatedBy: "//")[0], properties: &localVariables)
                }
            } else {
                if line.contains(":") {
                    let cmps = line.trimmingCharacters(in: CharacterSet.whitespaces).components(separatedBy: ":")
                    let baloon = Int(cmps[0].trimmingCharacters(in: CharacterSet.whitespaces))
                    if cmps[1].trimmingCharacters(in: CharacterSet.whitespaces) == "{", baloon != nil {
                        inBaloonBlock = baloon!
                        localVariables["closed"] = null
                        localVariables["opened"] = null
                        localVariables["openedGood"] = null
                        localVariables["closedFake"] = null
                        localVariables["openedFake"] = null
                        localVariables["extension.animationColor"] = null
                    } else {
                        print("Baloon block beginning must be on one line 'x: {'")
                        throw ExecErrors.syntaxError
                    }
                } else if line.contains("]") {
                    return // END
                }
            }
            self.line += 1
        }
    }
    
    func fileImage(_ stringLiteral: String) throws -> String? {
        let argument = try execIfNeeds(stringLiteral)!
        do {
            return try FileSaveHelper(fileName: argument, fileExtension: argument.contains(".") ? .NONE : .PNG, subDirectory: dir).getData().base64EncodedString(options: .lineLength64Characters)
        } catch {
            print("Couldn't get file content of \(argument)\(argument.contains(".") ? "" : ".png"): \(error)")
            throw error
        }
    }
    
    func unicolor(_ stringLiteral: String) throws -> String? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 0)
        try parseColor(stringLiteral).uiColor.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image.pngData()!.base64EncodedString(options: .lineLength64Characters)
    }
    
    func emptyImage(_: String) throws -> String? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 0)
        UIColor.clear.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image.pngData()!.base64EncodedString(options: .lineLength64Characters)
    }
    
    func issetSet(_ stringLiteral: String) throws -> String? {
        let cmps = stringLiteral.components(separatedBy: ",")
        if cmps.count != 2 {
            print("Invalid argument count")
            throw ExecErrors.syntaxError
        }
        do {
            try set(cmps[0].trimmingCharacters(in: CharacterSet.whitespaces), value: execIfNeeds(cmps[1].trimmingCharacters(in: CharacterSet.whitespaces))!)
        } catch {
            print("isset_set failed at line \(line)")
        }
        return nil
    }

    func localized(_ stringLiteral: String) throws -> String? {
        let cmps = stringLiteral.components(separatedBy: ",")
        var values: [String: String] = [:]
        for cmp in cmps {
            let vals = cmp.components(separatedBy: ":")
            if vals.count != 2 {
                print("There must be a ':' in each arguments of localized")
                throw ExecErrors.syntaxError
            }
            values[vals[0].trimmingCharacters(in: CharacterSet.whitespaces)] = try execIfNeeds(vals[1].trimmingCharacters(in: CharacterSet.whitespaces))
        }
        if values[NSLocalizedString("lang.code", comment: "")] != nil {
            return values[NSLocalizedString("lang.code", comment: "")]
        }
        if values["default"] != nil {
            return values["default"]
        }
        if values["en_US"] != nil {
            return values["en_US"]
        }
        return nil
    }
    
    func grayscale(_ variable: String, stringLiteral _: String) throws -> String? {
        if get(variable) == nil {
            print("Tried to grayscale a null image")
            throw ExecErrors.nullPointerError
        }
        let ciImage = CIImage(data: Data(base64Encoded: get(variable)!, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)!)!
        let grayscale = ciImage.applyingFilter("CIColorControls", parameters: [kCIInputSaturationKey: 0.0])
        let context = CIContext(options: nil)
        try set(variable, value: UIImage(cgImage: context.createCGImage(grayscale, from: grayscale.extent)!).pngData()!.base64EncodedString(options: .lineLength64Characters))
        return nil
    }
    
    func rotate(_ variable: String, stringLiteral: String) throws -> String? {
        if get(variable) == nil {
            print("Tried to rotate a null image")
            throw ExecErrors.nullPointerError
        }
        var radians: CGFloat
        if stringLiteral.hasSuffix("°") {
            var degrees = stringLiteral
            degrees.remove(at: stringLiteral.index(before: stringLiteral.endIndex))
            radians = CGFloat(Int(degrees)!) * (CGFloat.pi / 180)
        } else {
            radians = CGFloat(Float(stringLiteral)!)
        }
        try set(variable, value: rotateImpl(getImage(variable), radians: radians, flip: false).pngData()!.base64EncodedString(options: .lineLength64Characters))
        return nil
    }
    
    func rotateFlip(_ variable: String, stringLiteral: String) throws -> String? {
        if get(variable) == nil {
            print("Tried to rotate a null image")
            throw ExecErrors.nullPointerError
        }
        var radians: CGFloat
        if stringLiteral.hasSuffix("°") {
            var degrees = stringLiteral
            degrees.remove(at: stringLiteral.index(before: stringLiteral.endIndex))
            radians = CGFloat(Int(degrees)!) * (CGFloat.pi / 180)
        } else {
            radians = CGFloat(Float(stringLiteral)!)
        }
        try set(variable, value: rotateImpl(getImage(variable), radians: radians, flip: true).pngData()!.base64EncodedString(options: .lineLength64Characters))
        return nil
    }
    
    func pixelChange(_ variable: String, stringLiteral: String) throws -> String? {
        if get(variable) == nil {
            print("Tried to change pixels of a null image")
            throw ExecErrors.nullPointerError
        }
        if !stringLiteral.contains("->") {
            print("The syntax of replaceColors is 'var.replaceColors(COLOR1->COLOR2)'")
            throw ExecErrors.syntaxError
        }
        let cmps = stringLiteral.components(separatedBy: "->")
        try set(variable, value: pixelChangeImpl(getImage(variable).cgImage!, from: parseColor(cmps[0]), to: parseColor(cmps[1])).pngData()!.base64EncodedString(options: .lineLength64Characters))
        return nil
    }
    
    func imageDarker(_ variable: String, stringLiteral _: String) throws -> String? {
        // Get the original image and set up the CIExposureAdjust filter
        guard let inputImage = CIImage(image: getImage(variable)),
              let filter = CIFilter(name: "CIExposureAdjust") else { return nil }
        
        // The inputEV value on the CIFilter adjusts exposure (negative values darken, positive values brighten)
        filter.setValue(inputImage, forKey: "inputImage")
        filter.setValue(-2.0, forKey: "inputEV")
        
        // Break early if the filter was not a success (.outputImage is optional in Swift)
        guard let filteredImage = filter.outputImage else { return nil }
        
        let context = CIContext(options: nil)
        let output = UIImage(cgImage: context.createCGImage(filteredImage, from: filteredImage.extent)!)
        
        try set(variable, value: output.pngData()!.base64EncodedString(options: .lineLength64Characters))
        return nil
    }
    
    func imageBrighter(_ variable: String, stringLiteral _: String) throws -> String? {
        // Get the original image and set up the CIExposureAdjust filter
        guard let inputImage = CIImage(image: getImage(variable)),
              let filter = CIFilter(name: "CIExposureAdjust") else { return nil }
        
        // The inputEV value on the CIFilter adjusts exposure (negative values darken, positive values brighten)
        filter.setValue(inputImage, forKey: "inputImage")
        filter.setValue(2.0, forKey: "inputEV")
        
        // Break early if the filter was not a success (.outputImage is optional in Swift)
        guard let filteredImage = filter.outputImage else { return nil }
        
        let context = CIContext(options: nil)
        let output = UIImage(cgImage: context.createCGImage(filteredImage, from: filteredImage.extent)!)
        
        try set(variable, value: output.pngData()!.base64EncodedString(options: .lineLength64Characters))
        return nil
    }
    
    func add(_ variable: String, stringLiteral: String) throws -> String? {
        if get(variable) == nil {
            print("Tried to add image to a null image")
            throw ExecErrors.nullPointerError
        }
        try set(variable, value: concatImageImpl(getImage(variable), getImage(value: execIfNeeds(stringLiteral))).pngData()!.base64EncodedString(options: .lineLength64Characters))
        return nil
    }
    
    func concatImage(_ stringLiteral: String) throws -> String? {
        let images = stringLiteral.components(separatedBy: ",")
        if images.count < 2 {
            print("Invalid argument count")
            throw ExecErrors.syntaxError
        }
        var image = getImage(value: try execIfNeeds(images[0].trimmingCharacters(in: CharacterSet.whitespaces)))
        
        for i in 1 ..< images.count {
            image = concatImageImpl(image, getImage(value: try execIfNeeds(images[i].trimmingCharacters(in: CharacterSet.whitespaces))))
        }
        
        return image.pngData()!.base64EncodedString(options: .lineLength64Characters)
    }
    
    /// SO: 27092354
    func rotateImpl(_ image: UIImage, radians: CGFloat, flip: Bool) -> UIImage {
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPoint.zero, size: image.size))
        rotatedViewBox.transform = CGAffineTransform(rotationAngle: radians)
        
        UIGraphicsBeginImageContext(rotatedViewBox.frame.size)
        let bitmap = UIGraphicsGetCurrentContext()
        bitmap?.translateBy(x: rotatedViewBox.frame.width / 2.0, y: rotatedViewBox.frame.height / 2.0)
        bitmap?.rotate(by: radians)
        bitmap?.scaleBy(x: flip ? -1.0 : 1.0, y: -1.0)
        bitmap?.draw(image.cgImage!, in: CGRect(x: -image.size.width / 2, y: -image.size.height / 2, width: image.size.width, height: image.size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    /// SO: 31661023
    func pixelChangeImpl(_ input: CGImage, from: RGBA32, to: RGBA32) -> UIImage {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let width = input.width
        let height = input.height
        let bytesPerRow = 4 * width
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: RGBA32.bitmapInfo) else {
            print("Couldn't change pixels from \(from) to \(to) in image")
            print("\tat line \(line)")
            return UIImage(cgImage: input)
        }
        
        context.draw(input, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        guard let buffer = context.data else {
            print("Couldn't change pixels from \(from) to \(to) in image")
            print("\tat line \(line)")
            return UIImage(cgImage: input)
        }
        let pixelBuffer = buffer.bindMemory(to: RGBA32.self, capacity: width * height)
        var currentPixel = pixelBuffer
        
        for _ in 0 ..< height {
            for _ in 0 ..< width {
                if currentPixel.pointee == from {
                    currentPixel.pointee = to
                }
                currentPixel += 1
            }
        }
        
        return UIImage(cgImage: context.makeImage()!)
    }
    
    /// SO: 1309757
    func concatImageImpl(_ image1: UIImage, _ image2: UIImage) -> UIImage {
        print(image1.size, image2.size)
        let size = CGSize(width: max(image1.size.width, image2.size.width), height: max(image1.size.height, image2.size.height))
        UIGraphicsBeginImageContext(size)
        image1.withSize(size.width).draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.width))
        image2.withSize(size.width).draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.width))
        let image3 = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image3!
    }
    
    func parseColor(_ string: String) throws -> RGBA32 {
        if Int(string) != nil {
            return RGBA32(color: SKColor(rgbValue: UInt(string)!))
        } else if get(string) != nil {
            return try parseColor(get(string)!)
        }
        print("Invalid color: \(string)")
        throw ExecErrors.syntaxError
    }
    
    func toLower(_ variable: String, stringLiteral _: String) throws -> String? {
        if properties[variable] == nil || properties[variable]! == nil {
            print("Tried to lowercase a null string")
            throw ExecErrors.nullPointerError
        }
        try set(variable, value: get(variable)!.lowercased())
        return nil
    }
    
    func toUpper(_ variable: String, stringLiteral _: String) throws -> String? {
        if properties[variable] == nil || properties[variable]! == nil {
            print("Tried to uppercase a null string")
            throw ExecErrors.nullPointerError
        }
        try set(variable, value: get(variable)!.uppercased())
        return nil
    }
    
    func toCap(_ variable: String, stringLiteral _: String) throws -> String? {
        if properties[variable] == nil || properties[variable]! == nil {
            print("Tried to uppercase a null string")
            throw ExecErrors.nullPointerError
        }
        try set(variable, value: get(variable)!.capitalized)
        return nil
    }
    
    func equals(_ theme: AbstractTheme) -> Bool {
        return theme.themeID() == themeID()
    }
    
    func pumpSound(_ winner: Bool) -> Data {
        if properties["sound.\(winner ? "w" : "")pump"]! != nil {
            return properties["sound.\(winner ? "w" : "")pump"]!!.data(using: String.Encoding.utf8)!
        }
        return (try! Data(contentsOf: Bundle.main.url(forResource: "\(winner ? "w" : "")pump", withExtension: "wav")!))
    }
    
    func getBaloonTexture(case aCase: Case) -> SKTexture {
        if aCase is FakeCase {
            return getBaloonTexture(status: aCase.status, type: aCase.type, fake: true)
        }
        return getBaloonTexture(status: aCase.status, type: aCase.type, fake: false)
    }
    
    func getBaloonTexture(status: Case.CaseStatus, type: Int, fake: Bool) -> SKTexture {
        return SKTexture(image: (fake ? status == .closed ? baloons[type].3 : baloons[type].4 : status == .closed ? baloons[type].0 : status == .winnerOpened ? baloons[type].2 : baloons[type].1).withSize(75))
    }
    
    func numberOfBaloons() -> UInt {
        return UInt(baloons.count)
    }
    
    func animationColor(type: Int) -> UIColor? {
        return animationColors[type]
    }
    
    func backgroundColor() -> UIColor {
        return properties["theme.background"]! == nil ? UIColor.white : UIColor(rgbValue: UInt(properties["theme.background"]!!)!)
    }
    
    func themeID() -> String {
        return properties["theme.id"]! == nil ? "Undefined" : properties["theme.id"]!!
    }
    
    func themeName() -> String {
        return properties["theme.name"]! == nil ? "Undefined" : properties["theme.name"]!!
    }
    
    func themeVersion() -> String {
        return properties["theme.version"]! == nil ? "Undefined" : properties["theme.version"]!!
    }
    
    func themeAuthor() -> String {
        return properties["theme.author"]! == nil ? "Undefined" : properties["theme.author"]!!
    }
    
    func themeDescription() -> String {
        return properties["theme.description"]! == nil ? "Undefined" : properties["theme.description"]!!
    }
    
    func getImage(_ variable: String, default or: String? = nil) -> UIImage {
        return getImage(value: get(variable), default: or)
    }
    
    func getImage(value string: String?, default or: String? = nil) -> UIImage {
        if string != nil {
            let data = Data(base64Encoded: string!, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
            if data != nil {
                let image = UIImage(data: data!)
                if image != nil {
                    return image!
                }
            }
        }
        if or != nil {
            return getImage(or!)
        } else {
            return UIImage()
        }
    }
    
    enum ExecErrors: Error {
        case assignUndeclaredVariableError
        case callUndeclaredMethodError
        case syntaxError
        case nullPointerError
        case editConstantError
    }
}

struct RGBA32: Equatable {
    static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
    var color: UInt32
    var uiColor: UIColor {
        return UIColor(rgbValue: UInt(color))
    }
    
    init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        color = (UInt32(red) << 24) | (UInt32(green) << 16) | (UInt32(blue) << 8) | UInt32(alpha)
    }
    
    init(color: UIColor) {
        let ci = CIColor(color: color)
        self.init(red: UInt8(ci.red * 0xFF), green: UInt8(ci.green * 0xFF), blue: UInt8(ci.blue * 0xFF), alpha: UInt8(ci.alpha * 0xFF))
    }
}

func == (lhs: RGBA32, rhs: RGBA32) -> Bool {
    return lhs.color == rhs.color
}
