//
//  SettingScene.swift
//  BreakBaloon
//
//  Created by Emil on 21/06/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import AVFoundation
import SpriteKit

class SettingScene:SKScene {
    let FONT = "ChalkboardSE-Light"
    var previous:StartScene
    var ok = SKSpriteNode()
    var tok = SKLabelNode()
    var reset = SKSpriteNode()
    var treset = SKLabelNode()
    var extensions = SKSpriteNode()
    var textensions = SKLabelNode()
    var login = SKSpriteNode()
    var tlogin = SKLabelNode()
    
    var audioSetting:AudioSlider
    var musicSetting:AudioSlider
    var musicIndexSetting:MusicSelector
    var themeIndexSetting:ThemeSelector
    
    convenience init(previous: StartScene) {
        self.init(previous, (previous.view?.window?.rootViewController as! GameViewController))
    }
    
    init(_ previous: StartScene, _ gvc:GameViewController) {
        self.previous = previous
        audioSetting = AudioSlider(name: NSLocalizedString("settings.audio", comment: "Sound effects"), music: false, gvc: gvc)
        musicSetting = AudioSlider(name: NSLocalizedString("settings.music", comment: "Music"), music: true, gvc: gvc)
        musicIndexSetting = MusicSelector(gvc: gvc, importUnder: UIDevice.currentDevice().userInterfaceIdiom == .Phone)
        themeIndexSetting = ThemeSelector(gvc: gvc)
        super.init(size: previous.frame.size)
        self.backgroundColor = SKColor.brownColor()
        let name = SKLabelNode(text: NSLocalizedString("settings.title", comment: "Settings"))
        name.fontName = FONT
        name.fontColor = SKColor.blackColor()
        name.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.height - 50)
        addChild(name)
        
        audioSetting.setVolume(gvc.audioVolume)
        audioSetting.position = CGPointMake(self.frame.width/2, self.frame.height - 150)
        addChild(audioSetting)
        musicSetting.setVolume(gvc.backgroundMusicPlayer.volume)
        musicSetting.position = CGPointMake(self.frame.width/2, self.frame.height - 250)
        addChild(musicSetting)
        musicIndexSetting.position = CGPointMake(self.frame.width/2, self.frame.height - 300)
        addChild(musicIndexSetting)
        themeIndexSetting.position = CGPointMake(self.frame.width/2, self.frame.height - (UIDevice.currentDevice().userInterfaceIdiom == .Phone ? 450 : 350))
        addChild(themeIndexSetting)
        
        extensions = SKSpriteNode(imageNamed: "buttonminibg")
        extensions.position = CGPointMake(self.frame.width/3, self.frame.height - (UIDevice.currentDevice().userInterfaceIdiom == .Phone ? 500 : 400))
        extensions.zPosition = 1
        addChild(extensions)
        textensions = SKLabelNode(text: NSLocalizedString("settings.extensions", comment: "Extensions"))
        textensions.fontName = FONT
        textensions.fontColor = SKColor.blackColor()
        textensions.fontSize = 20
        textensions.position = CGPointMake(self.frame.width/3, self.frame.height - (UIDevice.currentDevice().userInterfaceIdiom == .Phone ? 510 : 410))
        textensions.zPosition = 2
        addChild(textensions)
        
        login = SKSpriteNode(imageNamed: "buttonminibg")
        login.position = CGPointMake(self.frame.width/3*2, self.frame.height - (UIDevice.currentDevice().userInterfaceIdiom == .Phone ? 500 : 400))
        login.zPosition = 1
        addChild(login)
        tlogin = SKLabelNode(text: NSLocalizedString("settings.log\(GameViewController.isLoggedIn() ? "out" : "in")", comment: "login/out"))
        tlogin.fontName = FONT
        tlogin.fontColor = SKColor.blackColor()
        tlogin.fontSize = 20
        tlogin.position = CGPointMake(self.frame.width/3*2, self.frame.height - (UIDevice.currentDevice().userInterfaceIdiom == .Phone ? 510 : 410))
        tlogin.zPosition = 2
        addChild(tlogin)
        
        ok = SKSpriteNode(imageNamed: "buttonminibg")
        ok.position = CGPointMake(self.frame.width/3, 50)
        ok.zPosition = 1
        addChild(ok)
        tok = SKLabelNode(text: NSLocalizedString("ok", comment: "Ok"))
        tok.fontName = FONT
        tok.fontColor = SKColor.blackColor()
        tok.fontSize = 20
        tok.position = CGPointMake(self.frame.width/3, 40)
        tok.zPosition = 2
        addChild(tok)
        
        reset = SKSpriteNode(imageNamed: "buttonminibg")
        reset.position = CGPointMake(self.frame.width/3*2, 50)
        reset.zPosition = 1
        addChild(reset)
        treset = SKLabelNode(text: NSLocalizedString("reset", comment: "Reset settings"))
        treset.fontName = FONT
        treset.fontColor = SKColor.blackColor()
        treset.fontSize = 20
        treset.position = CGPointMake(self.frame.width/3*2, 40)
        treset.zPosition = 2
        addChild(treset)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if(touches.count == 1) {
            let touch = touches.first!
            let point = touch.locationInNode(self)
            if onNode(ok, point: point) {
                close()
            } else if onNode(reset, point: point) {
                resetSettings()
            } else if onNode(extensions, point: point) {
                showExtConfig()
            } else if onNode(login, point: point) {
                dispatch_async(dispatch_get_main_queue()) {
                    if GameViewController.isLoggedIn() {
                        GameViewController.logOut()
                        self.updateLoginLabel()
                    } else {
                        (self.view!.window!.rootViewController! as! GameViewController).logInDialog(completion: self.updateLoginLabel)
                    }
                }
            } else if onNode(audioSetting, point: point) {
                audioSetting.calculateVolume(touch)
            } else if onNode(musicSetting, point: point) {
                musicSetting.calculateVolume(touch)
            } else if onNode(musicIndexSetting.importBtn, point: touch.locationInNode(musicIndexSetting)) {
                musicIndexSetting.showImportDialog()
            } else if onNode(musicIndexSetting, point: point) {
                musicIndexSetting.click(touch)
            } else if onNode(themeIndexSetting, point: point) {
                themeIndexSetting.click(touch)
            }
        }
    }
    
    func updateLoginLabel() {
        tlogin.text = NSLocalizedString("settings.log\(GameViewController.isLoggedIn() ? "out" : "in")", comment: "login/out")
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if(touches.count == 1) {
            let touch = touches.first!
            let point = touch.locationInNode(self)
            if onNode(audioSetting, point: point) {
                audioSetting.calculateVolume(touch)
            } else if onNode(musicSetting, point: point) {
                musicSetting.calculateVolume(touch)
            }
        }
    }
    
    func resetSettings() {
        audioSetting.setVolume(GameViewController.DEFAULT_AUDIO)
        musicSetting.setVolume(GameViewController.DEFAULT_MUSIC)
        musicIndexSetting.reset()
    }
    
    func close() {
        self.view?.presentScene(previous, transition: SKTransition.doorsCloseHorizontalWithDuration(NSTimeInterval(1)))
    }
    
    func showExtConfig() {
        let scene = ExtensionSettingScene(self)
        self.view?.presentScene(scene, transition: SKTransition.pushWithDirection(.Left, duration: NSTimeInterval(1)))
        scene.initialize()
    }
    
    func onNode(node:SKNode, point:CGPoint) -> Bool {
        return node.frame.contains(point)
    }
}