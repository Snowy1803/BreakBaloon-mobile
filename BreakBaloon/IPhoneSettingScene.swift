//
//  IPhoneSettingScene.swift
//  BreakBaloon
//
//  Created by Emil on 01/07/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit

class IPhoneSettingScene: SKScene {//For iPhone 4S only
    let start:StartScene
    var music = SKSpriteNode()
    var other = SKSpriteNode()
    var back = SKSpriteNode()
    
    var tmusic = SKLabelNode()
    var tother = SKLabelNode()
    var tback = SKLabelNode()
    
    init(previous: StartScene) {
        self.start = previous
        super.init(size: previous.frame.size)
        self.backgroundColor = SKColor.brownColor()
        initPane()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initPane() {
        music = SKSpriteNode(texture: start.buttonTexture)
        music.position = CGPointMake(CGRectGetMidX(self.frame), start.getPositionYForButton(0, text: false))
        music.zPosition = 1
        self.addChild(music)
        tmusic.text = NSLocalizedString("setting.category.music", comment: "")
        tmusic.fontSize = 35
        tmusic.fontName = start.BUTTON_FONT
        tmusic.position = CGPointMake(CGRectGetMidX(self.frame), start.getPositionYForButton(0, text: true))
        tmusic.fontColor = SKColor.blackColor()
        tmusic.zPosition = 2
        self.addChild(tmusic)
        
        other = SKSpriteNode(texture: start.buttonTexture)
        other.position = CGPointMake(CGRectGetMidX(self.frame), start.getPositionYForButton(1, text: false))
        other.zPosition = 1
        self.addChild(other)
        tother.text = NSLocalizedString("setting.category.other", comment: "")
        tother.fontSize = 35
        tother.fontName = start.BUTTON_FONT
        tother.position = CGPointMake(CGRectGetMidX(self.frame), start.getPositionYForButton(1, text: true))
        tother.fontColor = SKColor.blackColor()
        tother.zPosition = 2
        self.addChild(tother)
        
        back = SKSpriteNode(texture: start.buttonTexture)
        back.position = CGPointMake(CGRectGetMidX(self.frame), back.frame.height/2)
        back.zPosition = 1
        self.addChild(back)
        tback.text = NSLocalizedString("back", comment: "")
        tback.fontSize = 35
        tback.fontName = start.BUTTON_FONT
        tback.position = CGPointMake(CGRectGetMidX(self.frame), back.frame.height/2 - 15)
        tback.fontColor = SKColor.blackColor()
        tback.zPosition = 2
        self.addChild(tback)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touches.count == 1 {
            let point = touches.first!.locationInNode(self)
            if music.frame.contains(point) {
                self.view?.presentScene(IPhoneMusicSettingScene(self), transition: SKTransition.pushWithDirection(.Left, duration: NSTimeInterval(1)))
            } else if other.frame.contains(point) {
                self.view?.presentScene(IPhoneOtherSettingScene(self), transition: SKTransition.pushWithDirection(.Left, duration: NSTimeInterval(1)))
            } else if back.frame.contains(point) {
                self.view?.presentScene(start, transition: SKTransition.doorsCloseHorizontalWithDuration(NSTimeInterval(1)))
            }
        }
    }
}

class IPhoneMusicSettingScene: SKScene {
    let settings:IPhoneSettingScene
    let musicSetting:AudioSlider
    let musicIndexSetting:MusicSelector
    
    var ok = SKSpriteNode()
    var reset = SKSpriteNode()
    let tok = SKLabelNode()
    let treset = SKLabelNode()
        
    init(_ previous: IPhoneSettingScene) {
        self.settings = previous
        musicSetting = AudioSlider(name: NSLocalizedString("settings.music", comment: "Music"), music: true, gvc: (previous.view?.window?.rootViewController as! GameViewController))
        musicIndexSetting = MusicSelector(gvc: (previous.view?.window?.rootViewController as! GameViewController), importUnder: UIDevice.currentDevice().userInterfaceIdiom == .Phone)
        super.init(size: previous.frame.size)
        self.backgroundColor = SKColor.brownColor()
        initPane()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initPane() {
        musicSetting.setVolume((settings.view?.window?.rootViewController as! GameViewController).backgroundMusicPlayer.volume)
        musicSetting.position = CGPointMake(self.frame.width/2, self.frame.height - 100)
        addChild(musicSetting)
        musicIndexSetting.position = CGPointMake(self.frame.width/2, self.frame.height - 175)
        addChild(musicIndexSetting)
        
        ok = SKSpriteNode(imageNamed: "buttonminibg")
        ok.position = CGPointMake(self.frame.width/3, 50)
        ok.zPosition = 1
        addChild(ok)
        tok.text = NSLocalizedString("ok", comment: "Ok")
        tok.fontName = settings.start.BUTTON_FONT
        tok.fontColor = SKColor.blackColor()
        tok.fontSize = 20
        tok.position = CGPointMake(self.frame.width/3, 40)
        tok.zPosition = 2
        addChild(tok)
        
        reset = SKSpriteNode(imageNamed: "buttonminibg")
        reset.position = CGPointMake(self.frame.width/3*2, 50)
        reset.zPosition = 1
        addChild(reset)
        treset.text = NSLocalizedString("reset", comment: "Reset settings")
        treset.fontName = settings.start.BUTTON_FONT
        treset.fontColor = SKColor.blackColor()
        treset.fontSize = 20
        treset.position = CGPointMake(self.frame.width/3*2, 40)
        treset.zPosition = 2
        addChild(treset)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if(touches.count == 1) {
            let touch = touches.first!
            let point = touch.locationInNode(self)
            if onNode(ok, point: point) {
                self.view?.presentScene(settings, transition: SKTransition.pushWithDirection(.Right, duration: NSTimeInterval(1)))
            } else if onNode(reset, point: point) {
                resetSettings()
            } else if onNode(musicSetting, point: point) {
                musicSetting.calculateVolume(touch)
            } else if onNode(musicIndexSetting.importBtn, point: touch.locationInNode(musicIndexSetting)) {
                musicIndexSetting.showImportDialog()
            } else if onNode(musicIndexSetting, point: point) {
                musicIndexSetting.click(touch)
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if(touches.count == 1) {
            let touch = touches.first!
            let point = touch.locationInNode(self)
            if onNode(musicSetting, point: point) {
                musicSetting.calculateVolume(touch)
            }
        }
    }
    
    func onNode(node:SKSpriteNode, point:CGPoint) -> Bool {
        return node.frame.contains(point)
    }
    
    func resetSettings() {
        musicSetting.setVolume(GameViewController.DEFAULT_MUSIC)
        musicIndexSetting.reset()
    }
}

class IPhoneOtherSettingScene: SKScene {
    let settings:IPhoneSettingScene
    let audioSetting:AudioSlider
    let themeIndexSetting:ThemeSelector
    
    var ok = SKSpriteNode()
    var reset = SKSpriteNode()
    let tok = SKLabelNode()
    let treset = SKLabelNode()
    
    init(_ previous: IPhoneSettingScene) {
        self.settings = previous
        audioSetting = AudioSlider(name: NSLocalizedString("settings.audio", comment: "Sound effects"), music: false, gvc: (previous.view?.window?.rootViewController as! GameViewController))
        themeIndexSetting = ThemeSelector(gvc: (previous.view?.window?.rootViewController as! GameViewController))
        super.init(size: previous.frame.size)
        self.backgroundColor = SKColor.brownColor()
        initPane()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initPane() {
        audioSetting.setVolume((settings.view?.window?.rootViewController as! GameViewController).audioVolume)
        audioSetting.position = CGPointMake(self.frame.width/2, self.frame.height - 100)
        addChild(audioSetting)
        themeIndexSetting.position = CGPointMake(self.frame.width/2, self.frame.height - 175)
        addChild(themeIndexSetting)
        
        ok = SKSpriteNode(imageNamed: "buttonminibg")
        ok.position = CGPointMake(self.frame.width/3, 50)
        ok.zPosition = 1
        addChild(ok)
        tok.text = NSLocalizedString("ok", comment: "Ok")
        tok.fontName = settings.start.BUTTON_FONT
        tok.fontColor = SKColor.blackColor()
        tok.fontSize = 20
        tok.position = CGPointMake(self.frame.width/3, 40)
        tok.zPosition = 2
        addChild(tok)
        
        reset = SKSpriteNode(imageNamed: "buttonminibg")
        reset.position = CGPointMake(self.frame.width/3*2, 50)
        reset.zPosition = 1
        addChild(reset)
        treset.text = NSLocalizedString("reset", comment: "Reset settings")
        treset.fontName = settings.start.BUTTON_FONT
        treset.fontColor = SKColor.blackColor()
        treset.fontSize = 20
        treset.position = CGPointMake(self.frame.width/3*2, 40)
        treset.zPosition = 2
        addChild(treset)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if(touches.count == 1) {
            let touch = touches.first!
            let point = touch.locationInNode(self)
            if onNode(ok, point: point) {
                self.view?.presentScene(settings, transition: SKTransition.pushWithDirection(.Right, duration: NSTimeInterval(1)))
            } else if onNode(reset, point: point) {
                resetSettings()
            } else if onNode(audioSetting, point: point) {
                audioSetting.calculateVolume(touch)
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if(touches.count == 1) {
            let touch = touches.first!
            let point = touch.locationInNode(self)
            if onNode(audioSetting, point: point) {
                audioSetting.calculateVolume(touch)
            }
        }
    }
    
    func onNode(node:SKSpriteNode, point:CGPoint) -> Bool {
        return node.frame.contains(point)
    }
    
    func resetSettings() {
        audioSetting.setVolume(GameViewController.DEFAULT_MUSIC)
    }
}