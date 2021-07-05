//
//  AudioSlider.swift
//  BreakBaloon
//
//  Created by Emil on 21/06/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import AVFoundation
import SpriteKit

class AudioSlider: SKSpriteNode {
    var volume: Float = 1.0 {
        didSet {
            didSetVolume()
        }
    }

    var slidericon: SKSpriteNode
    var tname: SKLabelNode
    var music: Bool
    var gvc: GameViewController
    
    init(name: String, music: Bool, gvc: GameViewController) {
        let texture = SKTexture(imageNamed: "slider")
        slidericon = SKSpriteNode(imageNamed: "slidericon")
        tname = SKLabelNode(text: name)
        self.music = music
        self.gvc = gvc
        super.init(texture: texture, color: SKColor.white, size: texture.size())
        setScale(2)
        slidericon.zPosition = 2
        addChild(slidericon)
        tname.position = CGPoint(x: 0, y: frame.height / 4 * 3)
        tname.fontName = "ChalkboardSE-Light"
        tname.fontColor = SKColor.black
        tname.fontSize = 12
        tname.zPosition = 3
        addChild(tname)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func calculateVolume(_ touch: UITouch) {
        volume = Float(touch.location(in: self).x * 2 / frame.width) + 0.5
    }
    
    private func didSetVolume() {
        slidericon.position = CGPoint(x: CGFloat(volume) / 2 * frame.width - 0.5 - frame.width / 4, y: frame.height / 4)
        if UIDevice.current.userInterfaceIdiom != .phone {
            tname.position = CGPoint(x: slidericon.position.x, y: frame.height / 4 * 3)
        }
        if music {
            gvc.backgroundMusicPlayer.volume = volume
        } else {
            gvc.audioVolume = volume
        }
        UserDefaults.standard.set(volume, forKey: "audio-\(music)")
    }
}
