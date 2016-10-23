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
    fileprivate(set) var value: Float = 1.0
    var slidericon: SKSpriteNode
    var tname: SKLabelNode
    var music:Bool
    var gvc:GameViewController
    
    init(name: String, music:Bool, gvc:GameViewController) {
        let texture = SKTexture(imageNamed: "slider")
        slidericon = SKSpriteNode(imageNamed: "slidericon")
        tname = SKLabelNode(text: name)
        self.music = music
        self.gvc = gvc
        super.init(texture: texture, color: SKColor.white, size: texture.size())
        self.setScale(2)
        slidericon.zPosition = 2
        addChild(slidericon)
        tname.position = CGPoint(x: 0, y: self.frame.height/4*3)
        tname.fontName = "ChalkboardSE-Light"
        tname.fontColor = SKColor.black
        tname.fontSize = 12
        tname.zPosition = 3
        addChild(tname)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setVolume(_ value: Float) {
        self.value = value
        slidericon.position = CGPoint(x: CGFloat(value) / 2 * self.frame.width - 0.5 - self.frame.width/4, y: self.frame.height/4)
        updateAfterVolumeChange()
    }
    
    func calculateVolume(_ touch: UITouch) {
        self.value = Float(touch.location(in: self).x * 2 / self.frame.width) + 0.5
        slidericon.position = CGPoint(x: touch.location(in: self).x, y: self.frame.height/4)
        updateAfterVolumeChange()
    }
    
    fileprivate func updateAfterVolumeChange() {
        if UIDevice.current.userInterfaceIdiom != .phone {
            tname.position = CGPoint(x: slidericon.position.x, y: self.frame.height/4*3)
        }
        if music {
            gvc.backgroundMusicPlayer.volume = value
        } else {
            gvc.audioVolume = value
        }
        UserDefaults.standard.set(value, forKey: "audio-\(music)")
    }
}
