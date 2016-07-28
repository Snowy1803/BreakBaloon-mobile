//
//  Downloadable.swift
//  BreakBaloon
//
//  Created by Emil on 27/06/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit

class Downloadable: SKNode {
    static let WIDTH:CGFloat = 300
    static let HEIGHT:CGFloat = 250
    
    var rect:SKShapeNode
    let dltype:DownloadType
    let dlname:String
    let dlauthor:String
    let dldescription: String
    let dlid:String
    let dlversion:String
    let levelRequirement:Int
    
    init(type:DownloadType, name:String, author:String, id:String, version:String, description:String, levelRequirement:Int) {
        self.dltype = type
        self.dlname = name
        self.dlauthor = author
        self.dldescription = description
        self.dlid = id
        self.dlversion = version
        self.levelRequirement = levelRequirement
        rect = SKShapeNode()
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func construct(gvc:GameViewController) {
        rect = SKShapeNode(rect: CGRectMake(position.x, position.y, Downloadable.WIDTH, Downloadable.HEIGHT))
        rect.fillColor = SKColor.lightGrayColor()
        rect.zPosition = 1
        addChild(rect)
        let name = SKLabelNode(text: dlname)
        name.color = SKColor.whiteColor()
        name.fontSize = 20
        name.position = CGPointMake(rect.frame.minX + name.frame.width / 2 + 5, rect.frame.maxY - 20)
        name.zPosition = 2
        addChild(name)
        let auth = SKLabelNode(text: dlauthor)
        auth.color = SKColor.whiteColor()
        auth.fontSize = 20
        auth.position = CGPointMake(rect.frame.maxX - auth.frame.width / 2 - 5, rect.frame.maxY - 20)
        auth.zPosition = 2
        addChild(auth)
        let btn = SKLabelNode(text: NSLocalizedString("bbstore.clickToDownload", comment: "button"))
        btn.color = SKColor.whiteColor()
        btn.fontSize = 16
        btn.position = CGPointMake(rect.frame.midX, rect.frame.minY + 5)
        btn.zPosition = 2
        addChild(btn)
        
        if isInPossession() {
            let lenght:CGFloat = 40
            let path = CGPathCreateMutable()
            CGPathMoveToPoint(path, nil, rect.frame.maxX, rect.frame.maxY - 30)
            CGPathAddLineToPoint(path, nil, rect.frame.maxX - (lenght + 25), rect.frame.maxY - 30)
            CGPathAddLineToPoint(path, nil, rect.frame.maxX - (lenght + 5), rect.frame.maxY - 45)
            CGPathAddLineToPoint(path, nil, rect.frame.maxX - (lenght + 25), rect.frame.maxY - 60)
            CGPathAddLineToPoint(path, nil, rect.frame.maxX, rect.frame.maxY - 60)
            let tooltip = SKShapeNode(path: path)
            tooltip.fillColor = isInUse(gvc) ? SKColor(red: 0.5, green: 1, blue: 0, alpha: 1) : SKColor(red: 0, green: 0.5, blue: 1, alpha: 1)
            tooltip.strokeColor = SKColor.clearColor()
            tooltip.zPosition = 3
            addChild(tooltip)
            let tttext = SKLabelNode(text: "✓")
            tttext.color = SKColor.whiteColor()
            tttext.fontSize = 30
            tttext.position = CGPointMake(rect.frame.maxX - tttext.frame.width / 2 - 5, rect.frame.maxY - 57)
            tttext.zPosition = 4
            addChild(tttext)
        }
        if levelRequirement > GameViewController.getLevel() {
            let disable = SKShapeNode(rect: rect.frame)
            disable.fillColor = SKColor(red: 0, green: 0, blue: 0, alpha: 0.5)
            disable.zPosition = 10
            addChild(disable)
            let level = SKSpriteNode(imageNamed: "level")
            level.position = CGPointMake(rect.frame.maxX - 24, rect.frame.minY + 24)
            level.zPosition = 11
            level.setScale(1.5)
            addChild(level)
            let tlevel = SKLabelNode(text: "\(levelRequirement)")
            tlevel.position = CGPointMake(rect.frame.maxX - 24, rect.frame.minY + 12)
            tlevel.fontName = "AppleSDGothicNeo-Bold"
            tlevel.fontSize = 24
            tlevel.fontColor = SKColor.whiteColor()
            tlevel.zPosition = 12
            addChild(tlevel)
        } else if levelRequirement == GameViewController.getLevel() && !isInPossession() {
            let tlevel = SKLabelNode(text: NSLocalizedString("level.new", comment: ""))
            tlevel.position = CGPointMake(rect.frame.maxX - 24, rect.frame.minY + 12)
            tlevel.fontName = "AppleSDGothicNeo-Bold"
            tlevel.fontSize = 24
            tlevel.fontColor = SKColor(red: 1, green: 170/255, blue: 85/255, alpha: 1)
            tlevel.zPosition = 4
            addChild(tlevel)
        }
    }
    
    func click(scene:BBStoreScene) {
        if levelRequirement <= GameViewController.getLevel() {
            let alert = UIAlertController(title: NSLocalizedString("bbstore.download.title", comment: ""), message: String(format: NSLocalizedString("bbstore.download.text", comment: ""), dlname), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("bbstore.download.button", comment: ""), style: .Default, handler:  {
                _ in do {
                    try self.download(scene, wait: false)
                } catch {
                    let alert = UIAlertController(title: NSLocalizedString("bbstore.download.title", comment: ""), message: String(format: NSLocalizedString("bbstore.download.error", comment: ""), self.dlname), preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("bbstore.download.button", comment: ""), style: .Default, handler: nil))
                    alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .Cancel, handler: nil))
                    scene.view!.window!.rootViewController!.presentViewController(alert, animated: true, completion: nil)
                }
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .Cancel, handler: nil))
            scene.view!.window!.rootViewController!.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func download(scene:BBStoreScene?, wait:Bool) throws {
        if !dltype.isSupported() {
            if scene != nil {
                let alert = UIAlertController(title: NSLocalizedString("bbstore.download.title", comment: ""), message: NSLocalizedString("bbstore.download.unsupported", comment: ""), preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .Default, handler: nil))
                scene!.view!.window!.rootViewController!.presentViewController(alert, animated: true, completion: nil)
            }
            return
        }
        print("Beginning download of", dlname)
        let file = FileSaveHelper(fileName: dlid, fileExtension: .NONE)
        file.download(NSURL(string: "http://elementalcube.esy.es/api/bbstore-dl.php?id=\(dlid)")!)
        do {
            if wait {
                try afterDownload(file)
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    do {
                        try self.afterDownload(file)
                    } catch {
                        print("Errored treating download asynchronisously:", error)
                    }
                }
            }
        } catch {
            throw error
        }
    }
    
    private func afterDownload(file:FileSaveHelper) throws {
        while !file.downloadedSuccessfully {
            if file.downloadError != nil {
                throw file.downloadError!
            }
        }
        if dltype == .Theme {
            let dir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            print("Data is from", file.fullyQualifiedPath)
            SSZipArchive.unzipFileAtPath(file.fullyQualifiedPath, toDestination: dir)
            Theme.reloadThemeList()
        }
    }
    
    func isInPossession() -> Bool {
        if dltype == .M4aMusic {
            for url in GameViewController.getMusicURLs() {
                let cmps = url.absoluteString.componentsSeparatedByString("/")
                if cmps[cmps.count - 1].stringByRemovingPercentEncoding! == dlid.stringByRemovingPercentEncoding! {
                    return true
                }
            }
        } else if dltype == .Theme {
            return Theme.withID(dlid.componentsSeparatedByString(".").first!) != nil
        }
        return false
    }
    
    func isInUse(gvc:GameViewController) -> Bool {
        if dltype == .M4aMusic {
            return dlid == gvc.currentMusicFileName
        } else if dltype == .Theme {
            return dlid == gvc.currentTheme.themeID
        }
        return false
    }
    
    class func loadAll(viewSize:CGSize, _ gvc:GameViewController) throws -> [Downloadable] {
        let list:NSMutableArray = NSMutableArray()
        let fsh:FileSaveHelper = FileSaveHelper(fileName: "bbstore", fileExtension: .TXT, subDirectory: "", directory: .CachesDirectory)
        fsh.download(NSURL(string: "http://elementalcube.esy.es/api/bbstore.php?mobile&v2&lang=\(NSLocalizedString("lang.code", comment: "lang code (example: en_US)"))")!)
        while !fsh.downloadedSuccessfully {
            if fsh.downloadError != nil {
                throw fsh.downloadError!
            }
        }//Wait for downloading is finished
        var file = ""
        do {
            file = try fsh.getContentsOfFile()
        } catch {
            print("Error \(error)")
        }
        let lines = file.componentsSeparatedByString("\n")
        var currentName:String = "", currentId:String = "", currentDescription:String = "", currentAuthor:String = "", currentVersion:String = "", currentType:Int = -1, currentLevelRequirement = 0
        let /*rows:Int = Int((viewSize.width - 30) % (Downloadable.WIDTH + 5)), */cols:Int = Int(viewSize.width / Downloadable.WIDTH)
        for line in lines {
            if line == "===============COCH===============" {
                if DownloadType.getType(currentType, id: currentId).isSupported() {
                    let dl = Downloadable(type: DownloadType.getType(currentType, id: currentId), name: currentName, author: currentAuthor, id: currentId, version: currentVersion, description: currentDescription, levelRequirement: currentLevelRequirement)
                    //dl.position = CGPointMake(viewSize.width/2, viewSize.height/2)
                    
                    list.addObject(dl)
                    currentName = ""
                    currentId = ""
                    currentDescription = ""
                    currentAuthor = ""
                    currentVersion = ""
                    currentLevelRequirement = 0
                    currentType = -1
                }
            } else if line.hasPrefix("ID=") {
                currentId = line.componentsSeparatedByString("=")[1]
            } else if line.hasPrefix("NAME=") {
                currentName = line.componentsSeparatedByString("=")[1]
            } else if line.hasPrefix("USERNAME=") {
                currentAuthor = line.componentsSeparatedByString("=")[1]
            } else if line.hasPrefix("VERSION=") {
                currentVersion = line.componentsSeparatedByString("=")[1]
            } else if line.hasPrefix("DESCRIPTION=") {
                currentDescription = line.componentsSeparatedByString("=")[1]
            } else if line.hasPrefix("TYPE=") {
                currentType = Int(line.componentsSeparatedByString("=")[1])!
            } else if line.hasPrefix("LEVEL-REQUIREMENT=") {
                currentLevelRequirement = Int(line.componentsSeparatedByString("=")[1])!
            }
        }
        list.sortUsingComparator({
            dl1, dl2 in
            if dl1.levelRequirement > GameViewController.getLevel() && dl1.levelRequirement > dl2.levelRequirement {
                return .OrderedDescending
            } else if dl2.levelRequirement > GameViewController.getLevel() && dl1.levelRequirement < dl2.levelRequirement {
                return .OrderedAscending
            }
            return .OrderedSame
        })
        var i = 0
        for dl in list {//Setting position after sorting
            (dl as! Downloadable).construct(gvc)
            (dl as! Downloadable).position = CGPointMake(CGFloat(i % cols) * (Downloadable.WIDTH + 5) + 5, viewSize.height - (CGFloat(i / cols) * (Downloadable.HEIGHT + 5) + 30 + Downloadable.HEIGHT))
            i += 1
        }
        if let array = list as NSArray as? [Downloadable] {
            return array
        }
        return []
    }
    
    enum DownloadType {
        case Theme
        case JavaExtension
        case WavMusic
        case M4aMusic
        case Unresolved
        
        static func getType(type:Int, id:String) -> DownloadType {
            if type == 0 {
                return .Theme
            } else if type == 1 {
                return .JavaExtension
            } else if type == 2 {
                if id.hasSuffix(".wav") {
                    return .WavMusic
                } else if id.hasSuffix(".m4a") {
                    return .M4aMusic
                }
            }
            return .Unresolved
        }
        
        static func getExtension(type:DownloadType) -> FileSaveHelper.FileExtension {
            switch type {
            case .Theme:
                return .ZIP
            case .JavaExtension:
                return .JAR
            case .WavMusic:
                return .WAV
            case .M4aMusic:
                return .M4A
            default:
                return .NONE
            }
        }
        
        func isSupported() -> Bool {
            if #available(iOS 9.0, *) {
                return self == .Theme || self == .M4aMusic
            }
            return self == .M4aMusic
        }
    }
}