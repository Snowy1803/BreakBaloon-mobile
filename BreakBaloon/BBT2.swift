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
    let null:String? = nil
    
    let dir: String
    
    var functions: [String: ((String) throws -> String?)] = [:]
    var methods: [String: ((String, String) throws -> String?)] = [:]
    var properties: [String: String?] = [:]
    var localVariables: [String: String?] = [:]
    var constants: [String: String?] = [:]
    var baloons: [(UIImage, UIImage, UIImage, UIImage, UIImage)] = []
    var animationColors:[UIColor?] = []
    
    let completeCode: String
    var line = 0
    
    init(dir: String, code: String) throws {
        self.dir = dir
        self.completeCode = code
        let lines = code.componentsSeparatedByString("\n")
        // MARK: constants & default properties
        constants["_PLATFORM_OS"] = "iOS"
        constants["_PLATFORM_DEVICE_MODEL"] = UIDevice.currentDevice().localizedModel
        constants["_PLATFORM_DEVICE_NAME"] = UIDevice.currentDevice().name
        constants["_PLATFORM_VERSION"] = UIDevice.currentDevice().systemVersion
        constants["_BREAKBALOON_VERSION"] = "1.0.0"
        constants["_BBTC_VERSION"] = "0.1.23"
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
        for line in 0..<lines.count {
            if !lines[line].hasPrefix("//") {
                for cmd in lines[line].componentsSeparatedByString("//")[0].componentsSeparatedByString(";") {
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
                try exec(cmd.1)
            } catch {
                print("\tat line \(line + 1)")
                throw error
            }
        }
    }
    
    func exec(cmd: String) throws -> String? {
        return try exec(cmd, properties: properties)
    }
    
    func exec(cmd: String, properties: [String: String?]) throws -> String? {
        if cmd.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).hasPrefix("image.baloons") && cmd.containsString("=") {
            let vals = cmd.componentsSeparatedByString("=")
            if vals[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "[" {
                try parseBaloonBlock()
            } else {
                print("Invalid baloons declaration syntax")
                throw ExecErrors.AssignUndeclaredVariableError
            }
        } else if cmd.containsString("+=") {
            let varAndValToConcat = cmd.componentsSeparatedByString("+=")
            let variable = varAndValToConcat[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if properties[variable] != nil && properties[variable]! != nil {
                try set(variable, value: properties[variable]!! + execIfNeeds(varAndValToConcat[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))!)
                return properties[variable]!
            }
            print("Tried to concat a value to the undeclared variable \(variable)")
            throw ExecErrors.AssignUndeclaredVariableError
        } else if cmd.containsString("=") {
            // Assignation
            let vals = cmd.componentsSeparatedByString("=")
            let property = NSString(string: vals[0]).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if property.hasPrefix("val ") {
                constants[property.substringFromIndex(property.startIndex.advancedBy(4))] = try value(vals)
            } else if property.hasPrefix("var ") {
                try set(property.substringFromIndex(property.startIndex.advancedBy(4)), value: value(vals)!)
            } else if properties[property] != nil {
                try set(property, value: value(vals)!)
            } else {
                print("Tried to assign a value to the undeclared variable \(property)")
                throw ExecErrors.AssignUndeclaredVariableError
            }
        } else if cmd.containsString("(") {
            var components = cmd.componentsSeparatedByString("(")
            let methodName = components[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if functions[methodName] != nil {
                components.removeFirst()
                var arg = components.joinWithSeparator("(")
                let range = arg.rangeOfString(")", options: .BackwardsSearch)
                if range == nil {
                    print("Missing closing bracket ')'")
                    throw ExecErrors.SyntaxError
                }
                arg.removeRange(range!.startIndex..<arg.endIndex)
                return try functions[methodName]!(arg)
            }
            let lastDot = methodName.rangeOfString(".", options: .BackwardsSearch)!.startIndex
            if methods[methodName[lastDot.successor()..<methodName.endIndex]] != nil && valueExists(methodName[methodName.startIndex..<lastDot], properties: properties) {
                components.removeFirst()
                var arg = components.joinWithSeparator("(")
                let range = arg.rangeOfString(")", options: .BackwardsSearch)
                if range == nil {
                    print("Missing closing bracket ')'")
                    throw ExecErrors.SyntaxError
                }
                arg.removeRange(range!.startIndex..<arg.endIndex)
                return try methods[methodName[lastDot.successor()..<methodName.endIndex]]!(methodName[methodName.startIndex..<lastDot], arg)
            }
            print("Couldn't resolve \(methodName)")
            throw ExecErrors.CallUndeclaredMethodError
        }
        return null
    }
    
    func valueExists(name: String, properties: [String: String?]) -> Bool {
        return properties[name] != nil || constants[name] != nil || self.properties[name] != nil
    }
    
    func set(name: String, value: String) throws {
        if localVariables[name] != nil {
            localVariables[name] = value
        } else if properties[name] != nil {
            properties[name] = value
        } else if constants[name] != nil {
            print("Tried to edit a constant value")
            throw ExecErrors.EditConstantError
        }
    }
    
    func get(name: String) -> String? {
        if localVariables[name] != nil {
            return localVariables[name]!
        } else if constants[name] != nil {
            return constants[name]!
        } else if properties[name] != nil {
            return properties[name]!
        }
        return nil
    }
    
    func value(vals: [String]) throws -> String? {
        return vals.count == 1 ? null : try execIfNeeds(NSString(string: vals[1]).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
    }
    
    func execIfNeeds(cmd: String) throws -> String? {
        if cmd.lowercaseString == "null" {
            return null
        } else if localVariables[cmd] != nil {
            return localVariables[cmd]!
        } else if constants[cmd] != nil {
            return constants[cmd]!
        } else if properties[cmd] != nil {
            return properties[cmd]!
        } else if cmd.hasPrefix("\"") && cmd.hasSuffix("\"") && cmd.componentsSeparatedByString("\"").count == 3 {
            return cmd.stringByReplacingOccurrencesOfString("\\\\", withString: "\\").stringByReplacingOccurrencesOfString("\\n", withString: "\n").stringByReplacingOccurrencesOfString("\\t", withString: "\t").stringByReplacingOccurrencesOfString("\\r", withString: "\r").stringByReplacingOccurrencesOfString("\"", withString: "")
        } else if cmd.containsString("(") || cmd.containsString("=") {
            return try exec(cmd)
        } else if cmd.containsString("++") {
            var valsToConcat = cmd.componentsSeparatedByString("++")
            for i in 0..<valsToConcat.count {
                valsToConcat[i] = try execIfNeeds(valsToConcat[i].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))!
            }
            return valsToConcat.joinWithSeparator(" ")
        } else if cmd.containsString("+") {
            var valsToConcat = cmd.componentsSeparatedByString("+")
            for i in 0..<valsToConcat.count {
                valsToConcat[i] = try execIfNeeds(valsToConcat[i].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))!
            }
            return valsToConcat.joinWithSeparator("")
        }
        return cmd
    }
    
    func printString(stringLiteral: String) throws -> String? {
        print("[BBTC] [\(themeID())] \(try execIfNeeds(stringLiteral)!)")
        return nil
    }
    
    func parseBaloonBlock() throws {
        var inBaloonBlock = -1
        var cmps = completeCode.componentsSeparatedByString("\n")
        cmps.removeRange(0..<self.line)
        for line in cmps {
            if inBaloonBlock != -1 {
                if line.containsString("}") {
                    baloons.insert((getImage("closed"), getImage("opened"), getImage("openedGood", default: "opened"), getImage("closedFake"), getImage("openedFake")), atIndex: inBaloonBlock)
                    if localVariables["extension.animationColor"]! != nil {
                        animationColors.insert(UIColor(rgbValue: UInt(localVariables["extension.animationColor"]!!)!), atIndex: inBaloonBlock)
                    }
                    localVariables.removeAll()
                    inBaloonBlock = -1
                } else if line.containsString("]") {
                    print("Early baloon block array end")
                    throw ExecErrors.SyntaxError
                } else {
                    try exec(line.componentsSeparatedByString("//")[0], properties: localVariables)
                }
            } else {
                if line.containsString(":") {
                    let cmps = line.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).componentsSeparatedByString(":")
                    let baloon = Int(cmps[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
                    if cmps[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "{" && baloon != nil {
                        inBaloonBlock = baloon!
                        localVariables["closed"] = null
                        localVariables["opened"] = null
                        localVariables["openedGood"] = null
                        localVariables["closedFake"] = null
                        localVariables["openedFake"] = null
                        localVariables["extension.animationColor"] = null
                    } else {
                        print("Baloon block beginning must be on one line 'x: {'")
                        throw ExecErrors.SyntaxError
                    }
                } else if line.containsString("]") {
                    return // END
                }
            }
            self.line += 1
        }
    }
    
    func fileImage(stringLiteral: String) throws -> String? {
        let argument = try execIfNeeds(stringLiteral)!
        do {
            return try FileSaveHelper(fileName: argument, fileExtension: argument.containsString(".") ? .NONE : .PNG, subDirectory: dir).getData().base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        } catch {
            print("Couldn't get file content of \(argument)\(argument.containsString(".") ? "" : ".png"): \(error)")
            throw error
        }
    }
    
    func unicolor(stringLiteral: String) throws -> String? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 0)
        try parseColor(stringLiteral).uiColor.setFill()
        UIRectFill(CGRectMake(0, 0, 1, 1))
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIImagePNGRepresentation(image)!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
    }
    
    func emptyImage(stringLiteral: String) throws -> String? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 0)
        UIColor.clearColor().setFill()
        UIRectFill(CGRectMake(0, 0, 1, 1))
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIImagePNGRepresentation(image)!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
    }
    
    func issetSet(stringLiteral: String) throws -> String? {
        let cmps = stringLiteral.componentsSeparatedByString(",")
        if cmps.count != 2 {
            print("Invalid argument count")
            throw ExecErrors.SyntaxError
        }
        do {
            try set(cmps[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()), value: execIfNeeds(cmps[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))!)
        } catch {
            print("isset_set failed at line \(line)")
        }
        return nil
    }

    func localized(stringLiteral: String) throws -> String? {
        let cmps = stringLiteral.componentsSeparatedByString(",")
        var values: [String: String] = [:]
        for cmp in cmps {
            let vals = cmp.componentsSeparatedByString(":")
            if vals.count != 2 {
               print("There must be a ':' in each arguments of localized")
               throw ExecErrors.SyntaxError 
            }
            values[vals[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())] = execIfNeeds(vals[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
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
    
    func grayscale(variable: String, stringLiteral: String) throws -> String? {
        if get(variable) == nil {
            print("Tried to grayscale a null image")
            throw ExecErrors.NullPointerError
        }
        let ciImage = CIImage(data: NSData(base64EncodedString: get(variable)!, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!)!
        let grayscale = ciImage.imageByApplyingFilter("CIColorControls", withInputParameters: [ kCIInputSaturationKey: 0.0 ])
        let context = CIContext(options: nil)
        try set(variable, value: UIImagePNGRepresentation(UIImage(CGImage: context.createCGImage(grayscale, fromRect: grayscale.extent)))!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength))
        return nil
    }
    
    func rotate(variable: String, stringLiteral: String) throws -> String? {
        if get(variable) == nil {
            print("Tried to rotate a null image")
            throw ExecErrors.NullPointerError
        }
        var radians: CGFloat
        if stringLiteral.hasSuffix("°") {
            var degrees = stringLiteral
            degrees.removeAtIndex(stringLiteral.endIndex.predecessor())
            radians = CGFloat(Int(degrees)!) * (CGFloat(M_PI) / 180)
        } else {
            radians = CGFloat(Float(stringLiteral)!)
        }
        try set(variable, value: UIImagePNGRepresentation(rotateImpl(getImage(variable), radians: radians, flip: false))!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength))
        return nil
    }
    
    func rotateFlip(variable: String, stringLiteral: String) throws -> String? {
        if get(variable) == nil {
            print("Tried to rotate a null image")
            throw ExecErrors.NullPointerError
        }
        var radians: CGFloat
        if stringLiteral.hasSuffix("°") {
            var degrees = stringLiteral
            degrees.removeAtIndex(stringLiteral.endIndex.predecessor())
            radians = CGFloat(Int(degrees)!) * (CGFloat(M_PI) / 180)
        } else {
            radians = CGFloat(Float(stringLiteral)!)
        }
        try set(variable, value: UIImagePNGRepresentation(rotateImpl(getImage(variable), radians: radians, flip: true))!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength))
        return nil
    }
    
    func pixelChange(variable: String, stringLiteral: String) throws -> String? {
        if get(variable) == nil {
            print("Tried to change pixels of a null image")
            throw ExecErrors.NullPointerError
        }
        if !stringLiteral.containsString("->") {
            print("The syntax of replaceColors is 'var.replaceColors(COLOR1->COLOR2)'")
            throw ExecErrors.SyntaxError
        }
        let cmps = stringLiteral.componentsSeparatedByString("->")
        try set(variable, value: UIImagePNGRepresentation(pixelChangeImpl(getImage(variable).CGImage!, from: parseColor(cmps[0]), to: parseColor(cmps[1])))!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength))
        return nil
    }
    
    func imageDarker(variable: String, stringLiteral: String) throws -> String? {
        // Get the original image and set up the CIExposureAdjust filter
        guard let inputImage = CIImage(image: getImage(variable)),
            let filter = CIFilter(name: "CIExposureAdjust") else { return nil }
        
        // The inputEV value on the CIFilter adjusts exposure (negative values darken, positive values brighten)
        filter.setValue(inputImage, forKey: "inputImage")
        filter.setValue(-2.0, forKey: "inputEV")
        
        // Break early if the filter was not a success (.outputImage is optional in Swift)
        guard let filteredImage = filter.outputImage else { return nil }
        
        let context = CIContext(options: nil)
        let output = UIImage(CGImage: context.createCGImage(filteredImage, fromRect: filteredImage.extent))
        
        try set(variable, value: UIImagePNGRepresentation(output)!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength))
        return nil
    }
    
    func imageBrighter(variable: String, stringLiteral: String) throws -> String? {
        // Get the original image and set up the CIExposureAdjust filter
        guard let inputImage = CIImage(image: getImage(variable)),
            let filter = CIFilter(name: "CIExposureAdjust") else { return nil }
        
        // The inputEV value on the CIFilter adjusts exposure (negative values darken, positive values brighten)
        filter.setValue(inputImage, forKey: "inputImage")
        filter.setValue(2.0, forKey: "inputEV")
        
        // Break early if the filter was not a success (.outputImage is optional in Swift)
        guard let filteredImage = filter.outputImage else { return nil }
        
        let context = CIContext(options: nil)
        let output = UIImage(CGImage: context.createCGImage(filteredImage, fromRect: filteredImage.extent))
        
        try set(variable, value: UIImagePNGRepresentation(output)!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength))
        return nil
    }
    
    func add(variable: String, stringLiteral: String) throws -> String? {
        if get(variable) == nil {
            print("Tried to add image to a null image")
            throw ExecErrors.NullPointerError
        }
        try set(variable, value: UIImagePNGRepresentation(concatImageImpl(getImage(variable), getImage(value: execIfNeeds(stringLiteral))))!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength))
        return nil
    }
    
    func concatImage(stringLiteral: String) throws -> String? {
        let images = stringLiteral.componentsSeparatedByString(",")
        if images.count != 2 {
            print("Invalid argument count")
            throw ExecErrors.SyntaxError
        }
        
        let image1 = getImage(value: try execIfNeeds(images[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())))
        let image2 = getImage(value: try execIfNeeds(images[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())))
        
        return UIImagePNGRepresentation(concatImageImpl(image1, image2))!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
    }
    
    /// SO: 27092354
    func rotateImpl(image: UIImage, radians: CGFloat, flip: Bool) -> UIImage {
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPointZero, size: image.size))
        rotatedViewBox.transform = CGAffineTransformMakeRotation(radians)
        
        UIGraphicsBeginImageContext(rotatedViewBox.frame.size)
        let bitmap = UIGraphicsGetCurrentContext()
        CGContextTranslateCTM(bitmap, rotatedViewBox.frame.width / 2.0, rotatedViewBox.frame.height / 2.0)
        CGContextRotateCTM(bitmap, radians)
        CGContextScaleCTM(bitmap, flip ? -1.0 : 1.0, -1.0)
        CGContextDrawImage(bitmap, CGRectMake(-image.size.width / 2, -image.size.height / 2, image.size.width, image.size.height), image.CGImage)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// SO: 31661023
    func pixelChangeImpl(input: CGImage, from: RGBA32, to: RGBA32) -> UIImage {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let width = CGImageGetWidth(input)
        let height = CGImageGetHeight(input)
        let bytesPerRow = 4 * width
        
        guard let context = CGBitmapContextCreate(nil, width, height, 8, bytesPerRow, colorSpace, RGBA32.bitmapInfo) else {
            print("Couldn't change pixels from \(from) to \(to) in image")
            print("\tat line \(line)")
            return UIImage(CGImage: input)
        }
        
        CGContextDrawImage(context, CGRectMake(0, 0, CGFloat(width), CGFloat(height)), input)
        let pixelBuffer = UnsafeMutablePointer<RGBA32>(CGBitmapContextGetData(context))
        var currentPixel = pixelBuffer
        
        for _ in 0..<height {
            for _ in 0..<width {
                if currentPixel.memory == from {
                    currentPixel.memory = to
                }
                currentPixel += 1
            }
        }
        
        return UIImage(CGImage: CGBitmapContextCreateImage(context)!)
    }
    
    
    /// SO: 1309757
    func concatImageImpl(image1: UIImage, _ image2: UIImage) -> UIImage {
        print(image1.size, image2.size)
        let size = CGSize(width: max(image1.size.width, image2.size.width), height: max(image1.size.height, image2.size.height))
        UIGraphicsBeginImageContext(size)
        image1.withSize(size.width).drawInRect(CGRectMake(0, 0, size.width, size.width))
        image2.withSize(size.width).drawInRect(CGRectMake(0, 0, size.width, size.width))
        let image3 = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image3
    }
    
    func parseColor(string: String) throws -> RGBA32 {
        if Int(string) != nil {
            return RGBA32(color: SKColor(rgbValue: UInt(string)!))
        } else if get(string) != nil {
            return try parseColor(get(string)!)
        }
        print("Invalid color: \(string)")
        throw ExecErrors.SyntaxError
    }
    
    func toLower(variable: String, stringLiteral: String) throws -> String? {
        if properties[variable] == nil || properties[variable]! == nil {
            print("Tried to lowercase a null string")
            throw ExecErrors.NullPointerError
        }
        try set(variable, value: get(variable)!.lowercaseString)
        return nil
    }
    
    func toUpper(variable: String, stringLiteral: String) throws -> String? {
        if properties[variable] == nil || properties[variable]! == nil {
            print("Tried to uppercase a null string")
            throw ExecErrors.NullPointerError
        }
        try set(variable, value: get(variable)!.uppercaseString)
        return nil
    }
    
    func toCap(variable: String, stringLiteral: String) throws -> String? {
        if properties[variable] == nil || properties[variable]! == nil {
            print("Tried to uppercase a null string")
            throw ExecErrors.NullPointerError
        }
        try set(variable, value: get(variable)!.capitalizedString)
        return nil
    }
    
    func equals(theme: AbstractTheme) -> Bool {
        return theme.themeID() == self.themeID()
    }
    
    func pumpSound(winner: Bool) -> NSURL {
        // TODO
        return NSBundle.mainBundle().URLForResource("\(winner ? "w" : "")pump", withExtension: "wav")!
    }
    
    func getBaloonTexture(case aCase: Case) -> SKTexture {
        if aCase is FakeCase {
            return getBaloonTexture(status: aCase.status, type: aCase.type, fake: true)
        }
        return getBaloonTexture(status: aCase.status, type: aCase.type, fake: false)
    }
    
    func getBaloonTexture(status status: Case.CaseStatus, type: Int, fake: Bool) -> SKTexture {
        return SKTexture(image: (fake ? status == .Closed ? baloons[type].3 : baloons[type].4 : status == .Closed ? baloons[type].0 : status == .WinnerOpened ? baloons[type].2 : baloons[type].1).withSize(75))
    }
    
    func numberOfBaloons() -> UInt {
        return UInt(baloons.count)
    }
    
    func animationColor(type type: Int) -> UIColor? {
        return animationColors[type]
    }
    
    func backgroundColor() -> UIColor {
        return properties["theme.background"]! == nil ? UIColor.whiteColor() : UIColor(rgbValue: UInt(properties["theme.background"]!!)!)
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
    
    func getImage(variable: String, default or: String? = nil) -> UIImage {
        return getImage(value: get(variable), default: or)
    }
    
    func getImage(value string: String?, default or: String? = nil) -> UIImage {
        if string != nil {
            let data = NSData(base64EncodedString: string!, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
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
    
    enum ExecErrors: ErrorType {
        case AssignUndeclaredVariableError
        case CallUndeclaredMethodError
        case SyntaxError
        case NullPointerError
        case EditConstantError
    }
}

struct RGBA32: Equatable {
    static let bitmapInfo = CGImageAlphaInfo.PremultipliedLast.rawValue | CGBitmapInfo.ByteOrder32Little.rawValue
    var color: UInt32
    var uiColor: UIColor {
        get {
            return UIColor(rgbValue: UInt(color))
        }
    }
    
    init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        color = (UInt32(red) << 24) | (UInt32(green) << 16) | (UInt32(blue) << 8) | UInt32(alpha)
    }
    
    init(color: UIColor) {
        let ci = CIColor(color: color)
        self.init(red: UInt8(ci.red * 0xFF), green: UInt8(ci.green * 0xFF), blue: UInt8(ci.blue * 0xFF), alpha: UInt8(ci.alpha * 0xFF))
    }
}

func ==(lhs: RGBA32, rhs: RGBA32) -> Bool {
    return lhs.color == rhs.color
}
