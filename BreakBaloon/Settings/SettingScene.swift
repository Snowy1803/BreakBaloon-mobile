//
//  SettingScene.swift
//  BreakBaloon
//
//  Created by Emil on 21/06/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import AVFoundation
import SpriteKit

class SettingScene: SKScene {
    let FONT = "ChalkboardSE-Light"
    var previous: StartScene
    var ok = SKSpriteNode()
    var tok = SKLabelNode()
    var reset = SKSpriteNode()
    var treset = SKLabelNode()
    var extensions = SKSpriteNode()
    var textensions = SKLabelNode()
    var login = SKSpriteNode()
    var tlogin = SKLabelNode()
    
    var audioSetting: AudioSlider
    var musicSetting: AudioSlider
    var musicIndexSetting: MusicSelector
    var themeIndexSetting: ThemeSelector
    
    convenience init(previous: StartScene) {
        self.init(previous, previous.view?.window?.rootViewController as! GameViewController)
    }
    
    init(_ previous: StartScene, _ gvc: GameViewController) {
        self.previous = previous
        audioSetting = AudioSlider(name: NSLocalizedString("settings.audio", comment: "Sound effects"), music: false, gvc: gvc)
        musicSetting = AudioSlider(name: NSLocalizedString("settings.music", comment: "Music"), music: true, gvc: gvc)
        musicIndexSetting = MusicSelector(gvc: gvc, importUnder: UIDevice.current.userInterfaceIdiom == .phone)
        themeIndexSetting = ThemeSelector(gvc: gvc)
        super.init(size: previous.frame.size)
        backgroundColor = SKColor.brown
        let top = frame.height - (gvc.skView?.safeAreaInsets.top ?? 0)
        
        let name = SKLabelNode(text: NSLocalizedString("settings.title", comment: "Settings"))
        name.fontName = FONT
        name.fontColor = SKColor.black
        name.position = CGPoint(x: frame.midX, y: top - 50)
        addChild(name)
        
        audioSetting.setVolume(gvc.audioVolume)
        audioSetting.position = CGPoint(x: frame.width / 2, y: top - 150)
        addChild(audioSetting)
        musicSetting.setVolume(gvc.backgroundMusicPlayer.volume)
        musicSetting.position = CGPoint(x: frame.width / 2, y: top - 250)
        addChild(musicSetting)
        musicIndexSetting.position = CGPoint(x: frame.width / 2, y: top - 300)
        addChild(musicIndexSetting)
        themeIndexSetting.position = CGPoint(x: frame.width / 2, y: top - (UIDevice.current.userInterfaceIdiom == .phone ? 450 : 350))
        addChild(themeIndexSetting)
        
        extensions = SKSpriteNode(imageNamed: "buttonminibg")
        extensions.position = CGPoint(x: frame.width / 3, y: top - (UIDevice.current.userInterfaceIdiom == .phone ? 500 : 400))
        extensions.zPosition = 1
        addChild(extensions)
        textensions = SKLabelNode(text: NSLocalizedString("settings.extensions", comment: "Extensions"))
        textensions.fontName = FONT
        textensions.fontColor = SKColor.black
        textensions.fontSize = 20
        textensions.position = CGPoint(x: frame.width / 3, y: top - (UIDevice.current.userInterfaceIdiom == .phone ? 510 : 410))
        textensions.zPosition = 2
        addChild(textensions)
        
        login = SKSpriteNode(imageNamed: "buttonminibg")
        login.position = CGPoint(x: frame.width / 3 * 2, y: top - (UIDevice.current.userInterfaceIdiom == .phone ? 500 : 400))
        login.zPosition = 1
        addChild(login)
        tlogin = SKLabelNode(text: NSLocalizedString("settings.log\(GameViewController.isLoggedIn() ? "out" : "in")", comment: "login/out"))
        tlogin.fontName = FONT
        tlogin.fontColor = SKColor.black
        tlogin.fontSize = 20
        tlogin.position = CGPoint(x: frame.width / 3 * 2, y: top - (UIDevice.current.userInterfaceIdiom == .phone ? 510 : 410))
        tlogin.zPosition = 2
        addChild(tlogin)
        
        let bottom = gvc.skView?.safeAreaInsets.bottom ?? 0
        ok = SKSpriteNode(imageNamed: "buttonminibg")
        ok.position = CGPoint(x: frame.width / 3, y: 50 + bottom)
        ok.zPosition = 1
        addChild(ok)
        tok = SKLabelNode(text: NSLocalizedString("ok", comment: "Ok"))
        tok.fontName = FONT
        tok.fontColor = SKColor.black
        tok.fontSize = 20
        tok.position = CGPoint(x: frame.width / 3, y: 40 + bottom)
        tok.zPosition = 2
        addChild(tok)
        
        reset = SKSpriteNode(imageNamed: "buttonminibg")
        reset.position = CGPoint(x: frame.width / 3 * 2, y: 50 + bottom)
        reset.zPosition = 1
        addChild(reset)
        treset = SKLabelNode(text: NSLocalizedString("reset", comment: "Reset settings"))
        treset.fontName = FONT
        treset.fontColor = SKColor.black
        treset.fontSize = 20
        treset.position = CGPoint(x: frame.width / 3 * 2, y: 40 + bottom)
        treset.zPosition = 2
        addChild(treset)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with _: UIEvent?) {
        if touches.count == 1 {
            let touch = touches.first!
            let point = touch.location(in: self)
            if onNode(ok, point: point) {
                close()
            } else if onNode(reset, point: point) {
                resetSettings()
            } else if onNode(extensions, point: point) {
                showExtConfig()
            } else if onNode(login, point: point) {
                DispatchQueue.main.async {
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
            } else if onNode(musicIndexSetting.importBtn, point: touch.location(in: musicIndexSetting)) {
                musicIndexSetting.importBtn.showImportDialog()
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
    
    override func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent?) {
        if touches.count == 1 {
            let touch = touches.first!
            let point = touch.location(in: self)
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
        view?.presentScene(previous, transition: SKTransition.doorsCloseHorizontal(withDuration: TimeInterval(1)))
    }
    
    func showExtConfig() {
        let scene = ExtensionSettingScene(self)
        view?.presentScene(scene, transition: SKTransition.push(with: .left, duration: TimeInterval(1)))
        scene.initialize()
    }
    
    func onNode(_ node: SKNode, point: CGPoint) -> Bool {
        return node.frame.contains(point)
    }
}
