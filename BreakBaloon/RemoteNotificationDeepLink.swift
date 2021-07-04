//
//  RemoteNotificationDeepLink.swift
//  BreakBaloon
//
//  Created by Emil on 01/07/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class RemoteNotificationDeepLink: NSObject {
    var param: String = ""
    
    class func create(_ userInfo: [AnyHashable: Any]) -> RemoteNotificationDeepLink? {
        let info = userInfo as NSDictionary
        
        let settingPage = info.object(forKey: "settings") as? String
        let gameMode = info.object(forKey: "game") as? String
        let bbstore = info.object(forKey: "bbstore") as? String
        
        var ret: RemoteNotificationDeepLink?
        if settingPage != nil {
            ret = RemoteNotificationDeepLinkSettings(param: settingPage!)
        } else if gameMode != nil {
            ret = RemoteNotificationDeepLinkNewGame(param: gameMode!)
        } else if bbstore != nil {
            ret = RemoteNotificationDeepLinkBBStore(param: bbstore!)
        }
        return ret
    }
    
    override fileprivate init() {
        param = ""
        super.init()
    }
    
    fileprivate init(param: String) {
        self.param = param
        super.init()
    }
    
    final func trigger() {
        DispatchQueue.main.async {
            self.triggerImp { _ in
                // do nothing
            }
        }
    }
    
    fileprivate func triggerImp(_ completion: (AnyObject?) -> Void) {
        completion(nil)
    }
}

class RemoteNotificationDeepLinkSettings: RemoteNotificationDeepLink {
    override fileprivate func triggerImp(_ completion: (AnyObject?) -> Void) {
        super.triggerImp { _ in
                
            let gvc = (UIApplication.shared.delegate!.window!!.rootViewController as! GameViewController)
            let start = StartScene(size: gvc.view!.frame.size)
            var scene: SKScene?
                
            if start.littleScreen() {
                let root = IPhoneSettingScene(previous: start)
                if self.param == "music" {
                    scene = IPhoneMusicSettingScene(root)
                } else if self.param == "other" {
                    scene = IPhoneOtherSettingScene(root)
                } else if self.param == "extensions" {
                    scene = ExtensionSettingScene(root)
                } else {
                    scene = root
                }
            } else if self.param == "extensions" {
                scene = ExtensionSettingScene(SettingScene(StartScene(size: gvc.view!.frame.size), gvc))
            } else {
                scene = SettingScene(StartScene(size: gvc.view!.frame.size), gvc)
            }
                
            gvc.skView?.presentScene(scene)
                
            completion(nil)
        }
    }
}

class RemoteNotificationDeepLinkNewGame: RemoteNotificationDeepLink {
    override fileprivate func triggerImp(_ completion: (AnyObject?) -> Void) {
        super.triggerImp { _ in
                
            let gvc = (UIApplication.shared.delegate!.window!!.rootViewController as! GameViewController)
            // let start = StartScene(size: gvc.view!.frame.size)
            var scene: SKScene?
            if self.param == "singleplayer" {
                scene = GameScene(view: gvc.skView!, gametype: StartScene.GAMETYPE_SOLO, width: UInt(gvc.view!.frame.size.width / 70), height: UInt((gvc.view!.frame.size.height - 20) / 70))
            } else if self.param == "computer" {
                scene = GameScene(view: gvc.skView!, gametype: StartScene.GAMETYPE_COMPUTER, width: UInt(gvc.view!.frame.size.width / 70), height: UInt((gvc.view!.frame.size.height - 20) / 70))
            } else if self.param == "time" {
                scene = GameScene(view: gvc.skView!, gametype: StartScene.GAMETYPE_TIMED, width: UInt(gvc.view!.frame.size.width / 70), height: UInt((gvc.view!.frame.size.height - 20) / 70))
            } else if self.param.hasPrefix("randombaloons") {
                let level = RandGameLevel.levels[Int(self.param.components(separatedBy: "/")[1])! - 1]
                if level.canPlay() {
                    level.start(gvc.skView!)
                }
                // Avoid presentScene
                completion(nil)
                return
            } else if self.param.hasPrefix("singleplayer") {
                let ints = self.param.components(separatedBy: "ingleplayer")[1].components(separatedBy: "x")
                let width = UInt(ints[0])!, height = UInt(ints[1])!
                scene = GameScene(view: gvc.skView!, gametype: StartScene.GAMETYPE_SOLO, width: width, height: height)
            } else if self.param.hasPrefix("computer") {
                let ints = self.param.components(separatedBy: "omputer")[1].components(separatedBy: "x")
                let width = UInt(ints[0])!, height = UInt(ints[1])!
                scene = GameScene(view: gvc.skView!, gametype: StartScene.GAMETYPE_COMPUTER, width: width, height: height)
            } else if self.param.hasPrefix("time") {
                let ints = self.param.components(separatedBy: "ime")[1].components(separatedBy: "x")
                let width = UInt(ints[0])!, height = UInt(ints[1])!
                scene = GameScene(view: gvc.skView!, gametype: StartScene.GAMETYPE_TIMED, width: width, height: height)
            }
                
            gvc.skView?.presentScene(scene)
                
            completion(nil)
        }
    }
}

class RemoteNotificationDeepLinkBBStore: RemoteNotificationDeepLink {
    override fileprivate func triggerImp(_ completion: (AnyObject?) -> Void) {
        super.triggerImp { _ in
                
            let gvc = (UIApplication.shared.delegate!.window!!.rootViewController as! GameViewController)
            let scene = BBStoreScene(start: StartScene(size: gvc.view!.frame.size), size: gvc.view!.frame.size, gvc: gvc)
                
            gvc.skView?.presentScene(scene)
            if self.param != "none" {
                scene.simulateClickOnDownload(self.param)
            }
            completion(nil)
        }
    }
}
