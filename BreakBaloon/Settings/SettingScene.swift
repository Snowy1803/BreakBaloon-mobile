//
//  SettingScene.swift
//  BreakBaloon
//
//  Created by Emil on 21/06/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import AVFoundation
import SpriteKit

class SettingScene: SKScene, ECLoginDelegate {
    var previous: StartScene
    var ok: Button!
    var reset: Button!
    var extensions: Button!
    var login: Button!
    
    var audioSetting: AudioSlider
    var musicSetting: AudioSlider
    var musicIndexSetting: MusicSelector
    var themeIndexSetting: ThemeSelector
    
    convenience init(previous: StartScene) {
        self.init(previous, previous.view!.gvc)
    }
    
    init(_ previous: StartScene, _ gvc: GameViewController) {
        self.previous = previous
        audioSetting = AudioSlider(name: NSLocalizedString("settings.audio", comment: "Sound effects"), music: false, gvc: gvc)
        musicSetting = AudioSlider(name: NSLocalizedString("settings.music", comment: "Music"), music: true, gvc: gvc)
        musicIndexSetting = MusicSelector(gvc: gvc)
        themeIndexSetting = ThemeSelector(gvc: gvc)
        super.init(size: previous.frame.size)
        backgroundColor = SKColor.brown
        let top = frame.height - (gvc.skView?.safeAreaInsets.top ?? 0)
        
        let name = SKLabelNode(text: NSLocalizedString("settings.title", comment: "Settings"))
        name.fontName = Button.fontName
        name.fontColor = SKColor.black
        name.position = CGPoint(x: frame.midX, y: top - 50)
        addChild(name)
        
        audioSetting.volume = gvc.audioVolume
        audioSetting.position = CGPoint(x: frame.width / 2, y: top - 150)
        addChild(audioSetting)
        musicSetting.volume = gvc.backgroundMusicPlayer.volume
        musicSetting.position = CGPoint(x: frame.width / 2, y: top - 250)
        addChild(musicSetting)
        musicIndexSetting.position = CGPoint(x: frame.width / 2, y: top - 300)
        addChild(musicIndexSetting)
        themeIndexSetting.position = CGPoint(x: frame.width / 2, y: top - 400)
        addChild(themeIndexSetting)
        
        extensions = Button(size: .mini, text: NSLocalizedString("settings.extensions", comment: "Extensions"))
        extensions.position = CGPoint(x: frame.width / 3, y: top - 500)
        addChild(extensions)
        
        login = Button(size: .mini, text: NSLocalizedString("settings.log\(ECLoginManager.shared.loggedIn ? "out" : "in")", comment: "login/out"))
        login.position = CGPoint(x: frame.width / 3 * 2, y: top - 500)
        addChild(login)
        
        let bottom = gvc.skView?.safeAreaInsets.bottom ?? 0
        ok = Button(size: .mini, text: NSLocalizedString("ok", comment: "Ok"))
        ok.position = CGPoint(x: frame.width / 3, y: 50 + bottom)
        addChild(ok)
        
        reset = Button(size: .mini, text: NSLocalizedString("reset", comment: "Reset settings"))
        reset.position = CGPoint(x: frame.width / 3 * 2, y: 50 + bottom)
        addChild(reset)
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
                DispatchQueue.main.async { [self] in
                    if ECLoginManager.shared.loggedIn {
                        ECLoginManager.shared.logOut()
                        loginDidComplete()
                    } else {
                        ECLoginManager.shared.logInDialog(delegate: self)
                    }
                }
            } else if onNode(audioSetting, point: point) {
                audioSetting.calculateVolume(touch)
            } else if onNode(musicSetting, point: point) {
                musicSetting.calculateVolume(touch)
            } else if onNode(musicIndexSetting, point: point) {
                musicIndexSetting.click(touch)
            } else if onNode(themeIndexSetting, point: point) {
                themeIndexSetting.click(touch)
            }
        }
    }
    
    func present(alert: UIAlertController) {
        view?.gvc.present(alert, animated: true, completion: nil)
    }
    
    func loginDidComplete() {
        login.label.text = NSLocalizedString("settings.log\(ECLoginManager.shared.loggedIn ? "out" : "in")", comment: "login/out")
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
        audioSetting.volume = GameViewController.defaultAudioVolume
        musicSetting.volume = GameViewController.defaultMusicVolume
        musicIndexSetting.reset()
    }
    
    func close() {
        view?.presentScene(previous, transition: SKTransition.doorsCloseHorizontal(withDuration: 1))
    }
    
    func showExtConfig() {
        let scene = ExtensionSettingScene(self)
        view?.presentScene(scene, transition: SKTransition.push(with: .left, duration: 1))
        scene.initialize()
    }
    
    func onNode(_ node: SKNode, point: CGPoint) -> Bool {
        node.frame.contains(point)
    }
}
