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
    
    var methods: [String: ((String) throws -> String?)] = [:]
    var properties: [String: String?] = [:]
    var constants: [String: String?] = [:]
    
    init(dir: String, code: String) throws {
        self.dir = dir
        let lines = code.componentsSeparatedByString("\n")
        // MARK: default properties
        constants["_PLATFORM"] = "iOS"
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
        // MARK: methods
        methods["print"] = printString
        methods["fileGetContents"] = fileGetContents
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
        if cmd.containsString("="){
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
            if methods[methodName] != nil {
                components.removeFirst()
                var arg = components.joinWithSeparator("(")
                let range = arg.rangeOfString(")", options: .BackwardsSearch)
                if range == nil {
                    print("Missing closing bracket ')'")
                    throw ExecErrors.SyntaxError
                }
                arg.removeRange(range!.startIndex..<arg.endIndex)
                return try methods[methodName]!(arg)
            }
        }
        return null
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
        } else if cmd.hasPrefix("\"") && cmd.hasSuffix("\"") && cmd.componentsSeparatedByString("\"").count == 2 {
            return cmd.stringByReplacingOccurrencesOfString("\\\\", withString: "\\").stringByReplacingOccurrencesOfString("\\n", withString: "\n").stringByReplacingOccurrencesOfString("\\t", withString: "\t").stringByReplacingOccurrencesOfString("\\r", withString: "\r")
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
            return try FileSaveHelper(fileName: argument, fileExtension: argument.containsString(".") ? .NONE : .PNG, subDirectory: dir).getContentsOfFile()
        } catch {
            print("Couldn't get file content of \(argument)\(argument.containsString(".") ? "" : ".png"): \(error)")
            throw error
        }
    }
    
    func getThemeID() -> String {
        return properties["theme.id"]! == nil ? "Undefined" : properties["theme.id"]!!
    }
    
    enum ExecErrors: ErrorType {
        case AssignUndeclaredVariableError
        case CallUndeclaredMethodError
        case SyntaxError
    }
}