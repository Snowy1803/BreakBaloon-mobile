//
//  BBT2.swift
//  BreakBaloon
//
//  Created by Emil on 13/08/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import UIKit

class BBT2 {
    let null:String? = nil
    
    let dir: String
    
    var functions: [String: ((String) throws -> String?)] = [:]
    var methods: [String: ((String, String) throws -> String?)] = [:]
    var properties: [String: String?] = [:]
    var constants: [String: String?] = [:]
    
    init(dir: String, code: String) throws {
        self.dir = dir
        let lines = code.componentsSeparatedByString("\n")
        // MARK: constants & default properties
        constants["_PLATFORM_OS"] = "iOS"
        constants["_PLATFORM_DEVICE_MODEL"] = UIDevice.currentDevice().localizedModel
        constants["_PLATFORM_DEVICE_NAME"] = UIDevice.currentDevice().name
        constants["_PLATFORM_VERSION"] = UIDevice.currentDevice().systemVersion
        constants["_BREAKBALOON_VERSION"] = "1.0.0"
        properties["theme.id"] = null
        properties["theme.name"] = null
        properties["theme.description"] = null
        properties["theme.author"] = null
        properties["theme.version"] = null
        properties["image.icon"] = null
        properties["image.wicon"] = null
        properties["image.cursor"] = null
        // MARK: functions & methods
        functions["print"] = printString
        functions["fileGetContents"] = fileGetContents
        methods["blackAndWhite"] = blackAndWhite
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
            do {
                try exec(cmd.1)
            } catch {
                print("\tat line \(cmd.0 + 1)")
                throw error
            }
        }
    }
    
    func exec(cmd: String) throws -> String? {
        if cmd.containsString("+=") {
            let varAndValToConcat = cmd.componentsSeparatedByString("+=")
            let variable = varAndValToConcat[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if properties[variable] != nil && properties[variable]! != nil {
                properties[variable] = try properties[variable]!! + execIfNeeds(varAndValToConcat[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))!
                return properties[variable]!
            }
            print("Tried to concat a value to the undeclared variable \(variable)")
            throw ExecErrors.AssignUndeclaredVariableError
        } else if cmd.containsString("="){
            // Assignation
            let vals = cmd.componentsSeparatedByString("=")
            let property = NSString(string: vals[0]).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if property.hasPrefix("val ") {
                constants[property.substringFromIndex(property.startIndex.advancedBy(4))] = try value(vals)
            } else if property.hasPrefix("var ") {
                properties[property.substringFromIndex(property.startIndex.advancedBy(4))] = try value(vals)
            } else if properties[property] != nil {
                properties[property] = try value(vals)
            } else {
                print("Tried to assign a value to the undeclared variable \(property)")
                throw ExecErrors.AssignUndeclaredVariableError
            }
        } else if cmd.containsString("(") {
            var components = cmd.componentsSeparatedByString("(")
            let methodName = components[0]
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
            if methods[methodName[lastDot.successor()..<methodName.endIndex]] != nil && valueExists(methodName[methodName.startIndex..<lastDot]) {
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
        }
        return null
    }
    
    func valueExists(name: String) -> Bool {
        return constants[name] != nil || properties[name] != nil
    }
    
    func set(name: String, value: String) {
        if constants[name] != nil {
            constants[name] = value
        } else if properties[name] != nil {
            properties[name] = value
        }
    }
    
    func get(name: String) -> String? {
        if constants[name] != nil {
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
        print("[BBTC] [\(getThemeID())] \(try execIfNeeds(stringLiteral)!)")
        return nil
    }
    
    func fileGetContents(stringLiteral: String) throws -> String? {
        let argument = try execIfNeeds(stringLiteral)!
        do {
            return try FileSaveHelper(fileName: argument, fileExtension: argument.containsString(".") ? .NONE : .PNG, subDirectory: dir).getData().base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        } catch {
            print("Couldn't get file content of \(argument)\(argument.containsString(".") ? "" : ".png"): \(error)")
            throw error
        }
    }
    
    func blackAndWhite(variable: String, stringLiteral: String) throws -> String? {
        if get(variable) == nil {
            print("Tried to grayscale a null image")
            throw ExecErrors.NullPointerError
        }
        let ciImage = CIImage(data: NSData(base64EncodedString: get(variable)!, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!)!
        let grayscale = ciImage.imageByApplyingFilter("CIColorControls", withInputParameters: [ kCIInputSaturationKey: 0.0 ])
        set(variable, value: UIImagePNGRepresentation(UIImage(CIImage: grayscale))!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength))
        return nil
    }
    
    func getThemeID() -> String {
        return properties["theme.id"]! == nil ? "Undefined" : properties["theme.id"]!!
    }
    
    func getThemeName() -> String {
        return properties["theme.name"]! == nil ? "Undefined" : properties["theme.name"]!!
    }
    
    func getThemeVersion() -> String {
        return properties["theme.version"]! == nil ? "Undefined" : properties["theme.version"]!!
    }
    
    func getThemeAuthor() -> String {
        return properties["theme.author"]! == nil ? "Undefined" : properties["theme.author"]!!
    }
    
    func getThemeDescription() -> String {
        return properties["theme.description"]! == nil ? "Undefined" : properties["theme.description"]!!
    }
    
    func getBaloons() -> [(UIImage, UIImage, UIImage)] {
        return []
    }
    
    func getImage(variable: String) -> UIImage {
        return UIImage(data: NSData(base64EncodedString: get(variable)!, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!)!
    }
    
    enum ExecErrors: ErrorType {
        case AssignUndeclaredVariableError
        case CallUndeclaredMethodError
        case SyntaxError
        case NullPointerError
    }
}