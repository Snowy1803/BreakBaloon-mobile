//
//  IPhoneSettingScene.swift
//  BreakBaloon
//
//  Created by Emil on 01/07/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit

class IPhoneSettingScene: SKScene { // Used in landscape on iPhones
    let start:StartScene
    var music = SKSpriteNode()
    var other = SKSpriteNode()
    var extensions = SKSpriteNode()
    var login = SKSpriteNode()
    var back = SKSpriteNode()
    
    var tmusic = SKLabelNode()
    var tother = SKLabelNode()
    var textensions = SKLabelNode()
    var tlogin = SKLabelNode()
    var tback = SKLabelNode()
    
    init(previous: StartScene) {
        self.start = previous
        super.init(size: previous.frame.size)
        self.backgroundColor = SKColor.brown
        initPane()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initPane() {
        music = SKSpriteNode(texture: start.buttonTexture)
        music.position = CGPoint(x: self.frame.midX, y: start.getPositionYForButton(0, text: false))
        music.zPosition = 1
        self.addChild(music)
        tmusic.text = NSLocalizedString("setting.category.music", comment: "")
        tmusic.fontSize = 35
        tmusic.fontName = start.BUTTON_FONT
        tmusic.position = CGPoint(x: self.frame.midX, y: start.getPositionYForButton(0, text: true))
        tmusic.fontColor = SKColor.black
        tmusic.zPosition = 2
        self.addChild(tmusic)
        
        extensions = SKSpriteNode(texture: start.buttonTexture)
        extensions.position = CGPoint(x: self.frame.midX, y: start.getPositionYForButton(1, text: false))
        extensions.zPosition = 1
        self.addChild(extensions)
        textensions.text = NSLocalizedString("settings.extensions", comment: "")
        textensions.fontSize = 35
        textensions.fontName = start.BUTTON_FONT
        textensions.position = CGPoint(x: self.frame.midX, y: start.getPositionYForButton(1, text: true))
        textensions.fontColor = SKColor.black
        textensions.zPosition = 2
        self.addChild(textensions)
        
        login = SKSpriteNode(texture: start.buttonTexture)
        login.position = CGPoint(x: self.frame.midX, y: start.getPositionYForButton(2, text: false))
        login.zPosition = 1
        self.addChild(login)
        tlogin.text = NSLocalizedString("settings.log\(GameViewController.isLoggedIn() ? "out" : "in")", comment: "login/out")
        tlogin.fontSize = 35
        tlogin.fontName = start.BUTTON_FONT
        tlogin.position = CGPoint(x: self.frame.midX, y: start.getPositionYForButton(2, text: true))
        tlogin.fontColor = SKColor.black
        tlogin.zPosition = 2
        self.addChild(tlogin)
        
        other = SKSpriteNode(texture: start.buttonTexture)
        other.position = CGPoint(x: self.frame.midX, y: start.getPositionYForButton(3, text: false))
        other.zPosition = 1
        self.addChild(other)
        tother.text = NSLocalizedString("setting.category.other", comment: "")
        tother.fontSize = 35
        tother.fontName = start.BUTTON_FONT
        tother.position = CGPoint(x: self.frame.midX, y: start.getPositionYForButton(3, text: true))
        tother.fontColor = SKColor.black
        tother.zPosition = 2
        self.addChild(tother)
        
        back = SKSpriteNode(texture: start.buttonTexture)
        back.position = CGPoint(x: self.frame.midX, y: back.frame.height/2 + (start.view?.safeAreaInsets.bottom ?? 0))
        back.zPosition = 1
        self.addChild(back)
        tback.text = NSLocalizedString("back", comment: "")
        tback.fontSize = 35
        tback.fontName = start.BUTTON_FONT
        tback.position = CGPoint(x: self.frame.midX, y: back.frame.height/2 - 15 + (start.view?.safeAreaInsets.bottom ?? 0))
        tback.fontColor = SKColor.black
        tback.zPosition = 2
        self.addChild(tback)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 1 {
            let point = touches.first!.location(in: self)
            if music.frame.contains(point) {
                self.view?.presentScene(IPhoneMusicSettingScene(self), transition: SKTransition.push(with: .left, duration: TimeInterval(1)))
            } else if other.frame.contains(point) {
                self.view?.presentScene(IPhoneOtherSettingScene(self), transition: SKTransition.push(with: .left, duration: TimeInterval(1)))
            } else if extensions.frame.contains(point) {
                let scene = ExtensionSettingScene(self)
                self.view?.presentScene(scene, transition: SKTransition.push(with: .left, duration: TimeInterval(1)))
                scene.initialize()
            } else if login.frame.contains(point) {
                DispatchQueue.main.async {
                    if GameViewController.isLoggedIn() {
                        GameViewController.logOut()
                        self.updateLoginLabel()
                    } else {
                        (self.view!.window!.rootViewController! as! GameViewController).logInDialog(completion: self.updateLoginLabel)
                    }
                }
            } else if back.frame.contains(point) {
                self.view?.presentScene(start, transition: SKTransition.doorsCloseHorizontal(withDuration: TimeInterval(1)))
            }
        }
    }
    
    func updateLoginLabel() {
        tlogin.text = NSLocalizedString("settings.log\(GameViewController.isLoggedIn() ? "out" : "in")", comment: "login/out")
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
        musicIndexSetting = MusicSelector(gvc: (previous.view?.window?.rootViewController as! GameViewController), importUnder: UIDevice.current.userInterfaceIdiom == .phone)
        super.init(size: previous.frame.size)
        self.backgroundColor = SKColor.brown
        initPane()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initPane() {
        musicSetting.setVolume((settings.view?.window?.rootViewController as! GameViewController).backgroundMusicPlayer.volume)
        musicSetting.position = CGPoint(x: self.frame.width/2, y: self.frame.height - 100)
        addChild(musicSetting)
        musicIndexSetting.position = CGPoint(x: self.frame.width/2, y: self.frame.height - 175)
        addChild(musicIndexSetting)
        
        ok = SKSpriteNode(imageNamed: "buttonminibg")
        ok.position = CGPoint(x: self.frame.width/3, y: 50)
        ok.zPosition = 1
        addChild(ok)
        tok.text = NSLocalizedString("ok", comment: "Ok")
        tok.fontName = settings.start.BUTTON_FONT
        tok.fontColor = SKColor.black
        tok.fontSize = 20
        tok.position = CGPoint(x: self.frame.width/3, y: 40)
        tok.zPosition = 2
        addChild(tok)
        
        reset = SKSpriteNode(imageNamed: "buttonminibg")
        reset.position = CGPoint(x: self.frame.width/3*2, y: 50)
        reset.zPosition = 1
        addChild(reset)
        treset.text = NSLocalizedString("reset", comment: "Reset settings")
        treset.fontName = settings.start.BUTTON_FONT
        treset.fontColor = SKColor.black
        treset.fontSize = 20
        treset.position = CGPoint(x: self.frame.width/3*2, y: 40)
        treset.zPosition = 2
        addChild(treset)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(touches.count == 1) {
            let touch = touches.first!
            let point = touch.location(in: self)
            if onNode(ok, point: point) {
                self.view?.presentScene(settings, transition: SKTransition.push(with: .right, duration: TimeInterval(1)))
            } else if onNode(reset, point: point) {
                resetSettings()
            } else if onNode(musicSetting, point: point) {
                musicSetting.calculateVolume(touch)
            } else if onNode(musicIndexSetting.importBtn, point: touch.location(in: musicIndexSetting)) {
                musicIndexSetting.importBtn.showImportDialog()
            } else if onNode(musicIndexSetting, point: point) {
                musicIndexSetting.click(touch)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(touches.count == 1) {
            let touch = touches.first!
            let point = touch.location(in: self)
            if onNode(musicSetting, point: point) {
                musicSetting.calculateVolume(touch)
            }
        }
    }
    
    func onNode(_ node:SKSpriteNode, point:CGPoint) -> Bool {
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
        self.backgroundColor = SKColor.brown
        initPane()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initPane() {
        audioSetting.setVolume((settings.view?.window?.rootViewController as! GameViewController).audioVolume)
        audioSetting.position = CGPoint(x: self.frame.width/2, y: self.frame.height - 100)
        addChild(audioSetting)
        themeIndexSetting.position = CGPoint(x: self.frame.width/2, y: self.frame.height - 175)
        addChild(themeIndexSetting)
        
        ok = SKSpriteNode(imageNamed: "buttonminibg")
        ok.position = CGPoint(x: self.frame.width/3, y: 50)
        ok.zPosition = 1
        addChild(ok)
        tok.text = NSLocalizedString("ok", comment: "Ok")
        tok.fontName = settings.start.BUTTON_FONT
        tok.fontColor = SKColor.black
        tok.fontSize = 20
        tok.position = CGPoint(x: self.frame.width/3, y: 40)
        tok.zPosition = 2
        addChild(tok)
        
        reset = SKSpriteNode(imageNamed: "buttonminibg")
        reset.position = CGPoint(x: self.frame.width/3*2, y: 50)
        reset.zPosition = 1
        addChild(reset)
        treset.text = NSLocalizedString("reset", comment: "Reset settings")
        treset.fontName = settings.start.BUTTON_FONT
        treset.fontColor = SKColor.black
        treset.fontSize = 20
        treset.position = CGPoint(x: self.frame.width/3*2, y: 40)
        treset.zPosition = 2
        addChild(treset)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(touches.count == 1) {
            let touch = touches.first!
            let point = touch.location(in: self)
            if onNode(ok, point: point) {
                self.view?.presentScene(settings, transition: SKTransition.push(with: .right, duration: TimeInterval(1)))
            } else if onNode(reset, point: point) {
                resetSettings()
            } else if onNode(audioSetting, point: point) {
                audioSetting.calculateVolume(touch)
            } else if onNode(themeIndexSetting, point: point) {
                themeIndexSetting.click(touch)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(touches.count == 1) {
            let touch = touches.first!
            let point = touch.location(in: self)
            if onNode(audioSetting, point: point) {
                audioSetting.calculateVolume(touch)
            }
        }
    }
    
    func onNode(_ node:SKSpriteNode, point:CGPoint) -> Bool {
        return node.frame.contains(point)
    }
    
    func resetSettings() {
        audioSetting.setVolume(GameViewController.DEFAULT_MUSIC)
    }
}
