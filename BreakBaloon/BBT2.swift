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
    
    var methods: [String: ((String) -> Void)] = [:]
    var properties: [String: String?] = [:]
    var constants: [String: String?] = [:]
    
    init(code: String) throws {
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
    
    enum ExecErrors: ErrorType {
        case AssignUndeclaredVariableError
        case CallUndeclaredMethodError
    }
}