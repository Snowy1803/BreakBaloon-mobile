//
//  Theme.swift
//  BreakBaloon
//
//  Created by Emil on 04/07/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit

class Theme {
    static var themeList = Theme.getThemeList()
    
    let name:String
    let author:String
    let description:String
    let version:String
    let baloons:UInt
    let background:SKColor
    let themeID:String
    let differentBaloonsForPumpedGood:Bool
    //0:16711680;1:16776960;2:255;3:65280;4:16711935;5:8323199
    var animationColor:[Int: SKColor]?
    
    init(_ name:String, id:String, author:String, description:String, version:String, baloons:UInt, background:UInt, dbfpg:Bool) {
        self.name = name
        self.themeID = id
        self.author = author
        self.description = description
        self.version = version
        self.baloons = baloons
        self.background = Theme.colorFromRGB(background)
        self.differentBaloonsForPumpedGood = dbfpg
    }
    
    convenience init(_ name:String, id:String, author:String, description:String, version:String, baloons:String, background:String, dbfpg:Bool) {
        self.init(name, id: id, author: author, description: description, version: version,
                  baloons: UInt(baloons)!,
                  background: UInt(background)!, dbfpg: dbfpg)
    }
    
    func equals(other:Theme) -> Bool {
        return self.themeID == other.themeID
    }
    
    func getBaloonTexture(baloon:Case) -> SKTexture {
        return getBaloonTexture(status: baloon.status, type: baloon.type)
    }
    
    func getBaloonTexture(status status:Case.CaseStatus, type:Int) -> SKTexture {
        do {
            if status == .Closed {
                return SKTexture(image: try FileSaveHelper(fileName: "closed\(type)", fileExtension: .PNG, subDirectory: self.themeID).getImage())
            } else if differentBaloonsForPumpedGood  && status == .WinnerOpened {
                return SKTexture(image: try FileSaveHelper(fileName: "opened\(type)-good", fileExtension: .PNG, subDirectory: self.themeID).getImage())
            } else {
                return SKTexture(image: try FileSaveHelper(fileName: "opened\(type)", fileExtension: .PNG, subDirectory: self.themeID).getImage())
            }
        } catch {
            print("Error reading baloon texture of type \(type):", error)
        }
        return SKTexture()
    }
    
    func pumpSound(winner:Bool) -> NSURL {
        return NSURL(fileURLWithPath: FileSaveHelper(fileName: "\(winner ? "w" : "")pump", fileExtension: .WAV, subDirectory: self.themeID).fullyQualifiedPath)
    }
    
    class func colorFromRGB(rgbValue: UInt) -> SKColor {
        return SKColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    private class func getThemeList() -> [Theme] {
        var list = [Theme](arrayLiteral: DefaultTheme())
        for url in GameViewController.getExternalThemes() {
            let theme = Theme.parse(directoryUrl: url)
            if theme != nil {
                list.append(theme!)
            }
        }
        print(list)
        return list
    }
    
    class func reloadThemeList() {
        themeList = getThemeList()
    }
    
    class func parse(directoryUrl url:NSURL) -> Theme? {
        if url.isDirectory {//isDirectory is defined in GameViewController
            let file = FileSaveHelper(fileName: url.lastPathComponent!, fileExtension: .BBTHEME, subDirectory: url.lastPathComponent!)
            do {
                return try parse(id: url.lastPathComponent!, bbtheme: file.getContentsOfFile())
            } catch {
                print("Theme \(url.lastPathComponent!) doesn't contains any .bbtheme file")
            }
        }
        return nil
    }
    
    private class func parse(id id:String, bbtheme file:String) -> Theme {
        let lines = file.componentsSeparatedByString("\n")
        var name = "", author = "", desc = "", version = "", baloons = "", background = "16777215", dbfpg = false, animation: [Int: SKColor]?
        for line in lines {
            if line.componentsSeparatedByString("=").count > 1 {
                let value = line.componentsSeparatedByString("=")[1].stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\r\n\t "))
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
                    let array = value.componentsSeparatedByString(";")
                    for val in array {
                        let rgb = Int(val.componentsSeparatedByString(":")[1])!
                        animation![Int(val.componentsSeparatedByString(":")[0])!] = SKColor(red: CGFloat((rgb & 0xFF0000) >> 16) / 0xFF, green: CGFloat((rgb & 0x00FF00) >> 8) / 0xFF, blue: CGFloat(rgb & 0x0000FF) / 0xFF, alpha: 1.0)
                    }
                }
            }
        }
        let theme = Theme(name, id: id, author: author, description: desc, version: version, baloons: baloons, background: background, dbfpg: dbfpg)
        theme.animationColor = animation
        return theme
    }
    
    private class func isMetadata(line:String, metadata:String) -> Bool {
        return line.hasPrefix("\(metadata)=") || line.hasPrefix("\(metadata)_\(NSLocalizedString("lang.code", comment: "lang code (example: en_US)"))=")
    }
    
    class func withID(id:String) -> Theme? {
        let index = themeList.indexOf({theme in
            return theme.themeID == id
        })
        if index != nil {
            return themeList[index!]
        } else {
            return nil
        }
    }
}

class DefaultTheme: Theme {
    init() {
        super.init(NSLocalizedString("theme.default.name", comment: "Default theme name"), id: "/Default", author: "Snowy", description: "", version: "1.0", baloons: 6, background: 0xffffff, dbfpg: false)
        animationColor = [0: SKColor.redColor(), 1: SKColor.yellowColor(), 2: SKColor.blueColor(), 3: SKColor(red: 191/255, green: 1, blue: 0, alpha: 1), 4: SKColor(red: 1, green: 191/255, blue: 191/255, alpha: 1), 5: SKColor(red: 0.5, green: 0, blue: 1, alpha: 1)]
    }
    
    override func getBaloonTexture(status status:Case.CaseStatus, type:Int) -> SKTexture {
        if status == .Closed {
            return SKTexture(imageNamed: "closed\(type)")
        } else if differentBaloonsForPumpedGood  && status == .WinnerOpened {
            return SKTexture(imageNamed: "opened\(type)-good")
        } else {
            return SKTexture(imageNamed: "opened\(type)")
        }
    }
    
    override func pumpSound(winner:Bool) -> NSURL {
        return NSBundle.mainBundle().URLForResource("\(winner ? "w" : "")pump", withExtension: "wav")!
    }
}