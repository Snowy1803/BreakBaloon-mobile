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
    var beginTime:TimeInterval?
    var endTime:TimeInterval?
    fileprivate var pauseTime:TimeInterval?
    
    init(view:SKView, gametype:Int8) {
        self.gametype = gametype
        super.init(size: view.bounds.size)
        construct(view.window!.rootViewController as! GameViewController)
        (view.window!.rootViewController as! GameViewController).currentGame = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func construct(_ gvc: GameViewController) {
        self.backgroundColor = gvc.currentTheme.backgroundColor()
    }
    
    func pauseGame() {
        pauseTime = Date().timeIntervalSince1970
        isPaused = true
    }
    
    func quitPause() {
        isPaused = false
        if beginTime != nil && pauseTime != nil {
            let pauseLenght = Date().timeIntervalSince1970 - pauseTime!
            beginTime! += pauseLenght
        }
        pauseTime = nil
    }
    
    func isGamePaused() -> Bool {
        return pauseTime != nil
    }
}
