//
//  Downloadable.swift
//  BreakBaloon
//
//  Created by Emil on 27/06/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit
import ZIPFoundation

class Downloadable: SKNode {
    static let WIDTH: CGFloat = 300
    static let HEIGHT: CGFloat = 250
    
    var rect: SKShapeNode
    let dltype: DownloadType
    let dlname: String
    let dlauthor: String
    let dldescription: String
    let dlid: String
    let dlversion: String
    let levelRequirement: Int
    
    init(type: DownloadType, name: String, author: String, id: String, version: String, description: String, levelRequirement: Int) {
        dltype = type
        dlname = name
        dlauthor = author
        dldescription = description
        dlid = id
        dlversion = version
        self.levelRequirement = levelRequirement
        rect = SKShapeNode()
        super.init()
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func construct(_ gvc: GameViewController) {
        rect = SKShapeNode(rect: CGRect(x: position.x, y: position.y, width: Downloadable.WIDTH, height: Downloadable.HEIGHT))
        rect.fillColor = .groupTableViewBackground
        rect.strokeColor = .clear
        rect.zPosition = 1
        addChild(rect)
        let name = SKLabelNode(text: dlname)
        name.fontColor = .foreground
        name.fontSize = 20
        name.position = CGPoint(x: rect.frame.minX + name.frame.width / 2 + 5, y: rect.frame.maxY - 20)
        name.zPosition = 2
        addChild(name)
        let auth = SKLabelNode(text: dlauthor)
        auth.fontColor = .foreground
        auth.fontSize = 20
        auth.position = CGPoint(x: rect.frame.maxX - auth.frame.width / 2 - 5, y: rect.frame.maxY - 20)
        auth.zPosition = 2
        addChild(auth)
        let type = SKLabelNode(text: dltype.localizedDescription)
        type.fontColor = SKColor.gray
        type.fontSize = 20
        type.position = CGPoint(x: rect.frame.minX + type.frame.width / 2 + 5, y: rect.frame.maxY - 45)
        type.zPosition = 2
        addChild(type)
        let btn = SKLabelNode(text: NSLocalizedString("bbstore.clickToDownload", comment: "button"))
        btn.fontColor = .foreground
        btn.fontSize = 16
        btn.position = CGPoint(x: rect.frame.midX, y: rect.frame.minY + 5)
        btn.zPosition = 2
        addChild(btn)
        
        let desc = SKLabelNode(text: dldescription)
        desc.fontColor = .foreground
        desc.fontSize = 18
        desc.position = CGPoint(x: rect.frame.minX + 5, y: rect.frame.maxY - 50)
        desc.horizontalAlignmentMode = .left
        desc.verticalAlignmentMode = .top
        desc.preferredMaxLayoutWidth = Downloadable.WIDTH - 10
        desc.lineBreakMode = .byWordWrapping
        desc.numberOfLines = 6
        desc.zPosition = 2
        addChild(desc)
        
        if isInPossession() {
            let lenght: CGFloat = 40
            let path = CGMutablePath()
            path.move(to: CGPoint(x: rect.frame.maxX, y: rect.frame.maxY - 30))
            path.addLine(to: CGPoint(x: rect.frame.maxX - (lenght + 25), y: rect.frame.maxY - 30))
            path.addLine(to: CGPoint(x: rect.frame.maxX - (lenght + 5), y: rect.frame.maxY - 45))
            path.addLine(to: CGPoint(x: rect.frame.maxX - (lenght + 25), y: rect.frame.maxY - 60))
            path.addLine(to: CGPoint(x: rect.frame.maxX, y: rect.frame.maxY - 60))
            let tooltip = SKShapeNode(path: path)
            tooltip.fillColor = isInUse(gvc) ? SKColor(red: 0.5, green: 1, blue: 0, alpha: 1) : SKColor(red: 0, green: 0.5, blue: 1, alpha: 1)
            tooltip.strokeColor = SKColor.clear
            tooltip.zPosition = 3
            addChild(tooltip)
            let tttext = SKLabelNode(text: "✓")
            tttext.color = SKColor.white
            tttext.fontSize = 30
            tttext.position = CGPoint(x: rect.frame.maxX - tttext.frame.width / 2 - 5, y: rect.frame.maxY - 57)
            tttext.zPosition = 4
            addChild(tttext)
        }
        if levelRequirement > PlayerXP.currentLevel {
            let disable = SKShapeNode(rect: rect.frame)
            disable.fillColor = SKColor(red: 0, green: 0, blue: 0, alpha: 0.5)
            disable.zPosition = 10
            addChild(disable)
            let level = SKSpriteNode(imageNamed: "level")
            level.position = CGPoint(x: rect.frame.maxX - 24, y: rect.frame.minY + 24)
            level.zPosition = 11
            level.setScale(1.5)
            addChild(level)
            let tlevel = SKLabelNode(text: "\(levelRequirement)")
            tlevel.position = CGPoint(x: rect.frame.maxX - 24, y: rect.frame.minY + 12)
            tlevel.fontName = "AppleSDGothicNeo-Bold"
            tlevel.fontSize = 24
            tlevel.fontColor = SKColor.white
            tlevel.zPosition = 12
            addChild(tlevel)
        } else if levelRequirement == PlayerXP.currentLevel, !isInPossession() {
            let tlevel = SKLabelNode(text: NSLocalizedString("level.new", comment: ""))
            tlevel.fontName = "AppleSDGothicNeo-Bold"
            tlevel.fontSize = 24
            tlevel.position = CGPoint(x: rect.frame.maxX - tlevel.frame.width / 2 - 5, y: rect.frame.minY + 12)
            tlevel.fontColor = SKColor(red: 1, green: 170 / 255, blue: 85 / 255, alpha: 1)
            tlevel.zPosition = 4
            addChild(tlevel)
        }
    }
    
    func click(_ scene: BBStoreScene) {
        if levelRequirement <= PlayerXP.currentLevel {
            let alert = UIAlertController(title: NSLocalizedString("bbstore.download.title", comment: ""), message: String(format: NSLocalizedString("bbstore.download.text", comment: ""), dlname), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("bbstore.download.button", comment: ""), style: .default) { _ in
                do {
                    try self.download(scene, wait: false)
                } catch {
                    let alert = UIAlertController(title: NSLocalizedString("bbstore.download.title", comment: ""), message: String(format: NSLocalizedString("bbstore.download.error", comment: ""), self.dlname), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("bbstore.download.button", comment: ""), style: .default, handler: nil))
                    alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
                    scene.view!.window!.rootViewController!.present(alert, animated: true, completion: nil)
                }
            })
            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
            scene.view!.window!.rootViewController!.present(alert, animated: true, completion: nil)
        }
    }
    
    func download(_ scene: BBStoreScene?, wait: Bool) throws {
        if !dltype.supported {
            if scene != nil {
                let alert = UIAlertController(title: NSLocalizedString("bbstore.download.title", comment: ""), message: NSLocalizedString("bbstore.download.unsupported", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: nil))
                scene!.view!.window!.rootViewController!.present(alert, animated: true, completion: nil)
            }
            return
        }
        print("Beginning download of", dlname)
        let file = FileSaveHelper(fileName: dlid, fileExtension: .none)
        file.download(URL(string: "http://elementalcube.infos.st/api/bbstore-dl.php?id=\(dlid)")!)
        do {
            if wait {
                try afterDownload(file)
            } else {
                DispatchQueue.main.async {
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
    
    fileprivate func afterDownload(_ file: FileSaveHelper) throws {
        while !file.downloadedSuccessfully {
            if file.downloadError != nil {
                throw file.downloadError!
            }
        }
        if dltype.isTheme {
            let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            do {
                // remove previous version (same name without .zip extension)
                let zipFile = URL(fileURLWithPath: file.fullyQualifiedPath).lastPathComponent
                try FileManager.default.removeItem(atPath: "\(dir)/\(zipFile.dropLast(4))")
            } catch {
                print(error)
            }
            
            print("Data is from", file.fullyQualifiedPath)
            try FileManager.default.unzipItem(at: URL(fileURLWithPath: file.fullyQualifiedPath), to: URL(fileURLWithPath: dir))
            AbstractThemeUtils.reloadThemeList()
        }
    }
    
    func isInPossession() -> Bool {
        if dltype == .m4aMusic {
            for url in GameViewController.getMusicURLs() {
                let cmps = url.absoluteString.components(separatedBy: "/")
                if cmps[cmps.count - 1].removingPercentEncoding! == dlid.removingPercentEncoding! {
                    return true
                }
            }
        } else if dltype.isTheme {
            return AbstractThemeUtils.withID(dlid.components(separatedBy: ".").first!) != nil
        }
        return false
    }
    
    func isInUse(_ gvc: GameViewController) -> Bool {
        if dltype == .m4aMusic {
            return dlid == gvc.currentMusicFileName
        } else if dltype.isTheme {
            return dlid == gvc.currentTheme.id
        }
        return false
    }
    
    class func loadAll(gvc: GameViewController) throws -> [Downloadable] {
        var list: [Downloadable] = []
        let fsh = FileSaveHelper(fileName: "bbstore", fileExtension: .txt, subDirectory: "", directory: .cachesDirectory)
        fsh.download(URL(string: "http://elementalcube.infos.st/api/bbstore.php?mobile&v2&lang=\(NSLocalizedString("lang.code", comment: "lang code (example: en_US)"))")!)
        while !fsh.downloadedSuccessfully {
            if fsh.downloadError != nil {
                throw fsh.downloadError!
            }
        } // Wait for downloading is finished
        var file = ""
        do {
            file = try fsh.getContentsOfFile()
        } catch {
            print("Error \(error)")
        }
        let lines = file.components(separatedBy: "\n")
        var currentName: String = "", currentId: String = "", currentDescription: String = "", currentAuthor: String = "", currentVersion: String = "", currentType: Int = -1, currentLevelRequirement = 0
        for line in lines {
            if line == "===============COCH===============" {
                if DownloadType.getType(currentType, id: currentId).supported {
                    let dl = Downloadable(type: DownloadType.getType(currentType, id: currentId), name: currentName, author: currentAuthor, id: currentId, version: currentVersion, description: currentDescription, levelRequirement: currentLevelRequirement)
                    // dl.position = CGPointMake(viewSize.width/2, viewSize.height/2)
                    
                    list.append(dl)
                    currentName = ""
                    currentId = ""
                    currentDescription = ""
                    currentAuthor = ""
                    currentVersion = ""
                    currentLevelRequirement = 0
                    currentType = -1
                }
            } else if line.hasPrefix("ID=") {
                currentId = line.components(separatedBy: "=")[1]
            } else if line.hasPrefix("NAME=") {
                currentName = line.components(separatedBy: "=")[1]
            } else if line.hasPrefix("USERNAME=") {
                currentAuthor = line.components(separatedBy: "=")[1]
            } else if line.hasPrefix("VERSION=") {
                currentVersion = line.components(separatedBy: "=")[1]
            } else if line.hasPrefix("DESCRIPTION=") {
                currentDescription = line.components(separatedBy: "=")[1]
            } else if line.hasPrefix("TYPE=") {
                currentType = Int(line.components(separatedBy: "=")[1])!
            } else if line.hasPrefix("LEVEL-REQUIREMENT=") {
                currentLevelRequirement = Int(line.components(separatedBy: "=")[1])!
            }
        }
        list.sort(by: { dl1, dl2 in // move locked items to the end
            dl1.levelRequirement <= PlayerXP.currentLevel && dl2.levelRequirement > PlayerXP.currentLevel
        })
        for dl in list {
            dl.construct(gvc)
        }
        return list
    }
    
    enum DownloadType {
        case bbt1
        case javaExtension
        case wavMusic
        case m4aMusic
        case bbt2
        case unresolved
        
        static func getType(_ type: Int, id: String) -> DownloadType {
            if type == 0 {
                return .bbt1
            } else if type == 1 {
                return .javaExtension
            } else if type == 2 {
                if id.hasSuffix(".wav") {
                    return .wavMusic
                } else if id.hasSuffix(".m4a") {
                    return .m4aMusic
                }
            } else if type == 3 {
                return .bbt2
            }
            return .unresolved
        }
        
        static func getExtension(_ type: DownloadType) -> FileSaveHelper.FileExtension {
            switch type {
            case .bbt1, .bbt2:
                return .zip
            case .javaExtension:
                return .jar
            case .wavMusic:
                return .wav
            case .m4aMusic:
                return .m4a
            default:
                return .none
            }
        }
        
        var isTheme: Bool {
            self == .bbt1 || self == .bbt2
        }
        
        var supported: Bool {
            isTheme || self == .m4aMusic
        }
        
        var localizedDescription: String {
            switch self {
            case .bbt1, .bbt2:
                return NSLocalizedString("bbstore.type.theme", comment: "Theme")
            case .m4aMusic:
                return NSLocalizedString("bbstore.type.music", comment: "Music")
            default:
                return "UNSUPPORTED"
            }
        }
    }
}
