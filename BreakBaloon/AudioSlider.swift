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
    private(set) var value: Float = 1.0
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
        super.init(texture: texture, color: SKColor.whiteColor(), size: texture.size())
        self.setScale(2)
        slidericon.zPosition = 2
        addChild(slidericon)
        tname.position = CGPointMake(0, self.frame.height/4*3)
        tname.fontName = "ChalkboardSE-Light"
        tname.fontColor = SKColor.blackColor()
        tname.fontSize = 12
        tname.zPosition = 3
        addChild(tname)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setVolume(value: Float) {
        self.value = value
        slidericon.position = CGPointMake(CGFloat(value) / 2 * self.frame.width - 0.5 - self.frame.width/4, self.frame.height/4)
        updateAfterVolumeChange()
    }
    
    func calculateVolume(touch: UITouch) {
        self.value = Float(touch.locationInNode(self).x * 2 / self.frame.width) + 0.5
        slidericon.position = CGPointMake(touch.locationInNode(self).x, self.frame.height/4)
        updateAfterVolumeChange()
    }
    
    private func updateAfterVolumeChange() {
        if UIDevice.currentDevice().userInterfaceIdiom != .Phone {
            tname.position = CGPointMake(slidericon.position.x, self.frame.height/4*3)
        }
        if music {
            gvc.backgroundMusicPlayer.volume = value
        } else {
            gvc.audioVolume = value
        }
        NSUserDefaults.standardUserDefaults().setFloat(value, forKey: "audio-\(music)")
    }
}