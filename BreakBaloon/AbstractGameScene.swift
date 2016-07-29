//
//  AbstractGameScene.swift
//  BreakBaloon
//
//  Created by Emil on 29/07/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import AVFoundation
import SpriteKit

class AbstractGameScene: SKScene {
    var gametype:Int8
    
    var points:Int = 0
    
    var avplayer = AVAudioPlayer()
    var beginTime:NSTimeInterval?
    var endTime:NSTimeInterval?
    var pauseTime:NSTimeInterval?
    
    init(view:SKView, gametype:Int8) {
        self.gametype = gametype
        super.init(size: view.bounds.size)
        construct(view.window!.rootViewController as! GameViewController)
        (view.window!.rootViewController as! GameViewController).currentGame = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func construct(gvc: GameViewController) {
        self.backgroundColor = gvc.currentTheme.background
    }
    
    func pauseGame() {
        pauseTime = NSDate().timeIntervalSince1970
    }
    
    func quitPause() {
        if beginTime != nil {
            let pauseLenght = NSDate().timeIntervalSince1970 - pauseTime!
            beginTime! += pauseLenght
        }
        pauseTime = nil
    }
}