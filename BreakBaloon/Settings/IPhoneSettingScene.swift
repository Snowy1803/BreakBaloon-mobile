//
//  IPhoneSettingScene.swift
//  BreakBaloon
//
//  Created by Emil on 01/07/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit

class IPhoneSettingScene: SKScene, ECLoginDelegate { // Used in landscape on iPhones
    let start: StartScene
    var music: Button!
    var other: Button!
    var extensions: Button!
    var login: Button!
    var back: Button!
    
    init(previous: StartScene) {
        start = previous
        super.init(size: previous.frame.size)
        backgroundColor = SKColor.brown
        initPane()
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initPane() {
        music = Button(size: .normal, text: NSLocalizedString("setting.category.music", comment: ""))
        music.position = CGPoint(x: frame.midX, y: start.getPositionYForButton(0))
        addChild(music)
        
        extensions = Button(size: .normal, text: NSLocalizedString("settings.extensions", comment: ""))
        extensions.position = CGPoint(x: frame.midX, y: start.getPositionYForButton(1))
        addChild(extensions)
        
        login = Button(size: .normal, text: NSLocalizedString("settings.log\(ECLoginManager.shared.loggedIn ? "out" : "in")", comment: "login/out"))
        login.position = CGPoint(x: frame.midX, y: start.getPositionYForButton(2))
        addChild(login)
        
        other = Button(size: .normal, text: NSLocalizedString("setting.category.other", comment: ""))
        other.position = CGPoint(x: frame.midX, y: start.getPositionYForButton(3))
        addChild(other)
        
        back = Button(size: .normal, text: NSLocalizedString("back", comment: ""))
        back.position = CGPoint(x: frame.midX, y: back.frame.height / 2 + (start.view?.safeAreaInsets.bottom ?? 0))
        addChild(back)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with _: UIEvent?) {
        if touches.count == 1 {
            let point = touches.first!.location(in: self)
            if music.frame.contains(point) {
                view?.presentScene(IPhoneMusicSettingScene(self), transition: SKTransition.push(with: .left, duration: 1))
            } else if other.frame.contains(point) {
                view?.presentScene(IPhoneOtherSettingScene(self), transition: SKTransition.push(with: .left, duration: 1))
            } else if extensions.frame.contains(point) {
                let scene = ExtensionSettingScene(self)
                view?.presentScene(scene, transition: SKTransition.push(with: .left, duration: 1))
                scene.initialize()
            } else if login.frame.contains(point) {
                DispatchQueue.main.async { [self] in
                    if ECLoginManager.shared.loggedIn {
                        ECLoginManager.shared.logOut()
                        loginDidComplete()
                    } else {
                        ECLoginManager.shared.logInDialog(delegate: self)
                    }
                }
            } else if back.frame.contains(point) {
                view?.presentScene(start, transition: SKTransition.doorsCloseHorizontal(withDuration: 1))
            }
        }
    }
    
    func loginDidComplete() {
        login.label.text = NSLocalizedString("settings.log\(ECLoginManager.shared.loggedIn ? "out" : "in")", comment: "login/out")
    }
    
    func present(alert: UIAlertController) {
        view?.gvc.present(alert, animated: true, completion: nil)
    }
}

class IPhoneMusicSettingScene: SKScene {
    let settings: IPhoneSettingScene
    let musicSetting: AudioSlider
    let musicIndexSetting: MusicSelector
    
    var ok: Button!
    var reset: Button!
    
    init(_ previous: IPhoneSettingScene) {
        settings = previous
        musicSetting = AudioSlider(name: NSLocalizedString("settings.music", comment: "Music"), music: true, gvc: previous.view!.gvc)
        musicIndexSetting = MusicSelector(gvc: previous.view!.gvc)
        super.init(size: previous.frame.size)
        backgroundColor = SKColor.brown
        initPane()
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initPane() {
        musicSetting.volume = settings.view!.gvc.backgroundMusicPlayer.volume
        musicSetting.position = CGPoint(x: frame.width / 2, y: frame.height - 100)
        addChild(musicSetting)
        musicIndexSetting.position = CGPoint(x: frame.width / 2, y: frame.height - 175)
        addChild(musicIndexSetting)
        
        ok = Button(size: .mini, text: NSLocalizedString("ok", comment: "Ok"))
        ok.position = CGPoint(x: frame.width / 3, y: 50)
        addChild(ok)
        
        reset = Button(size: .mini, text: NSLocalizedString("reset", comment: "Reset settings"))
        reset.position = CGPoint(x: frame.width / 3 * 2, y: 50)
        addChild(reset)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with _: UIEvent?) {
        if touches.count == 1 {
            let touch = touches.first!
            let point = touch.location(in: self)
            if onNode(ok, point: point) {
                view?.presentScene(settings, transition: SKTransition.push(with: .right, duration: 1))
            } else if onNode(reset, point: point) {
                resetSettings()
            } else if onNode(musicSetting, point: point) {
                musicSetting.calculateVolume(touch)
            } else if onNode(musicIndexSetting, point: point) {
                musicIndexSetting.click(touch)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent?) {
        if touches.count == 1 {
            let touch = touches.first!
            let point = touch.location(in: self)
            if onNode(musicSetting, point: point) {
                musicSetting.calculateVolume(touch)
            }
        }
    }
    
    func onNode(_ node: SKSpriteNode, point: CGPoint) -> Bool {
        node.frame.contains(point)
    }
    
    func resetSettings() {
        musicSetting.volume = GameViewController.defaultMusicVolume
        musicIndexSetting.reset()
    }
}

class IPhoneOtherSettingScene: SKScene {
    let settings: IPhoneSettingScene
    let audioSetting: AudioSlider
    let themeIndexSetting: ThemeSelector
    
    var ok: Button!
    var reset: Button!
    
    init(_ previous: IPhoneSettingScene) {
        settings = previous
        audioSetting = AudioSlider(name: NSLocalizedString("settings.audio", comment: "Sound effects"), music: false, gvc: previous.view!.gvc)
        themeIndexSetting = ThemeSelector(gvc: previous.view!.gvc)
        super.init(size: previous.frame.size)
        backgroundColor = SKColor.brown
        initPane()
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initPane() {
        audioSetting.volume = settings.view!.gvc.audioVolume
        audioSetting.position = CGPoint(x: frame.width / 2, y: frame.height - 100)
        addChild(audioSetting)
        themeIndexSetting.position = CGPoint(x: frame.width / 2, y: frame.height - 175)
        addChild(themeIndexSetting)
        
        ok = Button(size: .mini, text: NSLocalizedString("ok", comment: "Ok"))
        ok.position = CGPoint(x: frame.width / 3, y: 50)
        addChild(ok)
        
        reset = Button(size: .mini, text: NSLocalizedString("reset", comment: "Reset settings"))
        reset.position = CGPoint(x: frame.width / 3 * 2, y: 50)
        addChild(reset)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with _: UIEvent?) {
        if touches.count == 1 {
            let touch = touches.first!
            let point = touch.location(in: self)
            if onNode(ok, point: point) {
                view?.presentScene(settings, transition: SKTransition.push(with: .right, duration: 1))
            } else if onNode(reset, point: point) {
                resetSettings()
            } else if onNode(audioSetting, point: point) {
                audioSetting.calculateVolume(touch)
            } else if onNode(themeIndexSetting, point: point) {
                themeIndexSetting.click(touch)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent?) {
        if touches.count == 1 {
            let touch = touches.first!
            let point = touch.location(in: self)
            if onNode(audioSetting, point: point) {
                audioSetting.calculateVolume(touch)
            }
        }
    }
    
    func onNode(_ node: SKSpriteNode, point: CGPoint) -> Bool {
        node.frame.contains(point)
    }
    
    func resetSettings() {
        audioSetting.volume = GameViewController.defaultMusicVolume
    }
}
