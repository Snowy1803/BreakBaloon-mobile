//
//  Theme.swift
//  BreakBaloon
//
//  Created by Emil on 04/07/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit

class BBT1: AbstractTheme {
    let name: String
    let author: String
    let description: String
    let version: String
    let baloons: UInt
    let background: SKColor
    let id: String
    let differentBaloonsForPumpedGood: Bool
    var animationColors: [Int: SKColor]?
    
    init(_ name: String, id: String, author: String, description: String, version: String, baloons: UInt, background: UInt, dbfpg: Bool) {
        self.name = name
        self.id = id
        self.author = author
        self.description = description
        self.version = version
        self.baloons = baloons
        self.background = SKColor(rgbValue: background)
        differentBaloonsForPumpedGood = dbfpg
    }
    
    convenience init(_ name: String, id: String, author: String, description: String, version: String, baloons: String, background: String, dbfpg: Bool) {
        self.init(name, id: id, author: author, description: description, version: version,
                  baloons: UInt(baloons)!,
                  background: UInt(background)!, dbfpg: dbfpg)
    }
    
    func equals(_ other: AbstractTheme) -> Bool {
        return themeID() == other.themeID()
    }
    
    func getBaloonTexture(case baloon: Case) -> SKTexture {
        if baloon is FakeCase {
            return getBaloonTexture(status: baloon.status, type: baloon.type, fake: true)
        }
        return getBaloonTexture(status: baloon.status, type: baloon.type, fake: false)
    }
    
    func getBaloonTexture(status: Case.CaseStatus, type: Int, fake: Bool) -> SKTexture {
        do {
            if fake {
                if status == .closed {
                    return SKTexture(image: try FileSaveHelper(fileName: "fake-closed\(type)", fileExtension: .png, subDirectory: themeID()).getImage())
                } else {
                    return SKTexture(image: try FileSaveHelper(fileName: "fake-opened\(type)", fileExtension: .png, subDirectory: themeID()).getImage())
                }
            } else {
                if status == .closed {
                    return SKTexture(image: try FileSaveHelper(fileName: "closed\(type)", fileExtension: .png, subDirectory: themeID()).getImage())
                } else if differentBaloonsForPumpedGood, status == .winnerOpened {
                    return SKTexture(image: try FileSaveHelper(fileName: "opened\(type)-good", fileExtension: .png, subDirectory: themeID()).getImage())
                } else {
                    return SKTexture(image: try FileSaveHelper(fileName: "opened\(type)", fileExtension: .png, subDirectory: themeID()).getImage())
                }
            }
        } catch {
            print("Error reading\(fake ? " fake" : "") baloon texture of type \(type):", error)
        }
        return SKTexture()
    }
    
    func numberOfBaloons() -> UInt {
        return baloons
    }
    
    func themeName() -> String {
        return name
    }
    
    func backgroundColor() -> UIColor {
        return background
    }
    
    func animationColor(type: Int) -> UIColor? {
        return animationColors == nil ? nil : animationColors![type]
    }
    
    func pumpSound(_ winner: Bool) -> Data {
        return (try? Data(contentsOf: URL(fileURLWithPath: FileSaveHelper(fileName: "\(winner ? "w" : "")pump", fileExtension: .wav, subDirectory: themeID()).fullyQualifiedPath))) ?? Data()
    }
    
    class func parse(id: String, bbtheme file: String) -> BBT1 {
        let lines = file.components(separatedBy: "\n")
        var name = "", author = "", desc = "", version = "", baloons = "", background = "16777215", dbfpg = false, animation: [Int: SKColor]?
        for line in lines {
            if line.components(separatedBy: "=").count > 1 {
                let value = line.components(separatedBy: "=")[1].trimmingCharacters(in: CharacterSet(charactersIn: "\r\n\t "))
                if isMetadata(line, metadata: "NAME") {
                    name = value
                } else if isMetadata(line, metadata: "DESCRIPTION") {
                    desc = value
                } else if isMetadata(line, metadata: "AUTHOR") {
                    author = value
                } else if isMetadata(line, metadata: "VERSION") {
                    version = value
                } else if isMetadata(line, metadata: "BALOONS") {
                    baloons = value
                } else if isMetadata(line, metadata: "BACKGROUND") {
                    background = value
                } else if isMetadata(line, metadata: "DIFFERENT-BALOON-PUMPED-GOOD") {
                    dbfpg = value == "true"
                } else if isMetadata(line, metadata: "ANIMATION-COLOR") {
                    animation = [:]
                    let array = value.components(separatedBy: ";")
                    for val in array {
                        let rgb = Int(val.components(separatedBy: ":")[1])!
                        animation![Int(val.components(separatedBy: ":")[0])!] = SKColor(red: CGFloat((rgb & 0xFF0000) >> 16) / 0xFF, green: CGFloat((rgb & 0x00FF00) >> 8) / 0xFF, blue: CGFloat(rgb & 0x0000FF) / 0xFF, alpha: 1.0)
                    }
                }
            }
        }
        let theme = BBT1(name, id: id, author: author, description: desc, version: version, baloons: baloons, background: background, dbfpg: dbfpg)
        theme.animationColors = animation
        return theme
    }
    
    fileprivate class func isMetadata(_ line: String, metadata: String) -> Bool {
        return line.hasPrefix("\(metadata)=") || line.hasPrefix("\(metadata)_\(NSLocalizedString("lang.code", comment: "lang code (example: en_US)"))=")
    }
    
    func themeID() -> String {
        return id
    }
}

class DefaultTheme: BBT1 {
    init() {
        super.init(NSLocalizedString("theme.default.name", comment: "Default theme name"), id: "/Default", author: "Snowy", description: "", version: "1.0", baloons: 6, background: 0xFFFFFF, dbfpg: false)
        animationColors = [0: SKColor.red, 1: SKColor.yellow, 2: SKColor.blue, 3: SKColor(red: 191 / 255, green: 1, blue: 0, alpha: 1), 4: SKColor(red: 1, green: 191 / 255, blue: 191 / 255, alpha: 1), 5: SKColor(red: 0.5, green: 0, blue: 1, alpha: 1)]
    }
    
    override func getBaloonTexture(status: Case.CaseStatus, type: Int, fake: Bool) -> SKTexture {
        if fake {
            if status == .closed {
                return SKTexture(imageNamed: "fake-closed\(type)")
            } else {
                return SKTexture(imageNamed: "fake-opened\(type)")
            }
        } else {
            if status == .closed {
                return SKTexture(imageNamed: "closed\(type)")
            } else if differentBaloonsForPumpedGood, status == .winnerOpened {
                return SKTexture(imageNamed: "opened\(type)-good")
            } else {
                return SKTexture(imageNamed: "opened\(type)")
            }
        }
    }
    
    override func pumpSound(_ winner: Bool) -> Data {
        // swiftlint:disable:next force_try
        return (try! Data(contentsOf: Bundle.main.url(forResource: "\(winner ? "w" : "")pump", withExtension: "wav")!))
    }
}
