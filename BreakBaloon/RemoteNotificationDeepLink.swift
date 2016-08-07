//
//  RemoteNotificationDeepLink.swift
//  BreakBaloon
//
//  Created by Emil on 01/07/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class RemoteNotificationDeepLink: NSObject {
    var param : String = ""
    
    class func create(userInfo : [NSObject : AnyObject]) -> RemoteNotificationDeepLink? {
        let info = userInfo as NSDictionary
        
        let settingPage = info.objectForKey("settings") as? String
        let gameMode = info.objectForKey("game") as? String
        let bbstore = info.objectForKey("bbstore") as? String
        
        var ret : RemoteNotificationDeepLink? = nil
        if settingPage != nil {
            ret = RemoteNotificationDeepLinkSettings(param: settingPage!)
        } else if gameMode != nil {
            ret = RemoteNotificationDeepLinkNewGame(param: gameMode!)
        } else if bbstore != nil {
            ret = RemoteNotificationDeepLinkBBStore(param: bbstore!)
        }
        return ret
    }
    
    private override init() {
        self.param = ""
        super.init()
    }
    
    private init(param: String) {
        self.param = param
        super.init()
    }
    
    final func trigger() {
        dispatch_async(dispatch_get_main_queue()) {
            self.triggerImp()
                { (passedData) in
                    // do nothing
            }
        }
    }
    
    private func triggerImp(completion: ((AnyObject?)->(Void))) {
        completion(nil)
    }
}

class RemoteNotificationDeepLinkSettings : RemoteNotificationDeepLink {
    private override func triggerImp(completion: ((AnyObject?)->(Void))) {
        super.triggerImp()
            { (passedData) in
                
                let gvc = (UIApplication.sharedApplication().delegate!.window!!.rootViewController as! GameViewController)
                let start = StartScene(size: gvc.view!.frame.size)
                var scene:SKScene?
                
                if start.littleScreen() {
                    scene = IPhoneSettingScene(previous: start)
                    if self.param == "music" {
                        scene = IPhoneMusicSettingScene(scene as! IPhoneSettingScene)
                    } else if self.param == "other" {
                        scene = IPhoneOtherSettingScene(scene as! IPhoneSettingScene)
                    } else if self.param == "extensions" {
                        scene = ExtensionSettingScene(scene as! IPhoneSettingScene)
                    }
                } else {
                    if self.param == "extensions" {
                        scene = ExtensionSettingScene(SettingScene(StartScene(size: gvc.view!.frame.size), gvc))
                    } else {
                        scene = SettingScene(StartScene(size: gvc.view!.frame.size), gvc)
                    }
                }
                
                gvc.skView?.presentScene(scene)
                
                completion(nil)
        }
    }
}

class RemoteNotificationDeepLinkNewGame : RemoteNotificationDeepLink {
    private override func triggerImp(completion: ((AnyObject?)->(Void))) {
        super.triggerImp()
            { (passedData) in
                
                let gvc = (UIApplication.sharedApplication().delegate!.window!!.rootViewController as! GameViewController)
                //let start = StartScene(size: gvc.view!.frame.size)
                var scene:SKScene?
                if self.param == "singleplayer" {
                    scene = GameScene(view: gvc.skView!, gametype: StartScene.GAMETYPE_SOLO, width: UInt(gvc.view!.frame.size.width / 70), height: UInt((gvc.view!.frame.size.height - 20) / 70))
                } else if self.param == "computer" {
                    scene = GameScene(view: gvc.skView!, gametype: StartScene.GAMETYPE_COMPUTER, width: UInt(gvc.view!.frame.size.width / 70), height: UInt((gvc.view!.frame.size.height - 20) / 70))
                } else if self.param == "time" {
                    scene = GameScene(view: gvc.skView!, gametype: StartScene.GAMETYPE_TIMED, width: UInt(gvc.view!.frame.size.width / 70), height: UInt((gvc.view!.frame.size.height - 20) / 70))
                } else if self.param.hasPrefix("randombaloons") {
                    let level = RandGameLevel.levels[Int(self.param.componentsSeparatedByString("/")[1])! - 1]
                    if level.canPlay() {
                        level.start(gvc.skView!)
                    }
                    //Avoid presentScene
                    completion(nil)
                    return
                } else if self.param.hasPrefix("singleplayer") {
                    let ints = self.param.componentsSeparatedByString("ingleplayer")[1].componentsSeparatedByString("x")
                    let width = UInt(ints[0])!, height = UInt(ints[1])!
                    scene = GameScene(view: gvc.skView!, gametype: StartScene.GAMETYPE_SOLO, width: width, height: height)
                } else if self.param.hasPrefix("computer") {
                    let ints = self.param.componentsSeparatedByString("omputer")[1].componentsSeparatedByString("x")
                    let width = UInt(ints[0])!, height = UInt(ints[1])!
                    scene = GameScene(view: gvc.skView!, gametype: StartScene.GAMETYPE_COMPUTER, width: width, height: height)
                } else if self.param.hasPrefix("time") {
                    let ints = self.param.componentsSeparatedByString("ime")[1].componentsSeparatedByString("x")
                    let width = UInt(ints[0])!, height = UInt(ints[1])!
                    scene = GameScene(view: gvc.skView!, gametype: StartScene.GAMETYPE_TIMED, width: width, height: height)
                }
                
                gvc.skView?.presentScene(scene)
                
                completion(nil)
        }
    }
}

class RemoteNotificationDeepLinkBBStore : RemoteNotificationDeepLink {
    private override func triggerImp(completion: ((AnyObject?)->(Void))) {
        super.triggerImp()
            { (passedData) in
                
                let gvc = (UIApplication.sharedApplication().delegate!.window!!.rootViewController as! GameViewController)
                let scene = BBStoreScene(start: StartScene(size: gvc.view!.frame.size), size: gvc.view!.frame.size, gvc: gvc)
                
                gvc.skView?.presentScene(scene)
                if self.param != "none" {
                    scene.simulateClickOnDownload(self.param)
                }
                completion(nil)
        }
    }
}