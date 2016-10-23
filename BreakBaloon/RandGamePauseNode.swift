//
//  RandGamePauseNode.swift
//  BreakBaloon
//
//  Created by Emil on 12/08/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit

class RandGamePauseNode: SKNode {
    let menu, play, replay: SKSpriteNode
    let grey: SKShapeNode
    let game: RandGameScene
    
    init(scene: RandGameScene) {
        self.game = scene
        grey = SKShapeNode(rect: scene.frame)
        grey.fillColor = SKColor(white: 0.5, alpha: 0.5)
        menu = SKSpriteNode(imageNamed: "levelback")
        play = SKSpriteNode(imageNamed: "levelback")
        play.zRotation = CGFloat(M_PI)
        replay = SKSpriteNode(imageNamed: "levelreplay")
        super.init()
        grey.zPosition = 3
        menu.position = CGPoint(x: scene.frame.width / 2 - 80, y: scene.frame.height / 2)
        menu.zPosition = 4
        play.position = CGPoint(x: scene.frame.width / 2, y: scene.frame.height / 2)
        play.zPosition = 4
        replay.position = CGPoint(x: scene.frame.width / 2 + 80, y: scene.frame.height / 2)
        replay.zPosition = 4
        addChild(grey)
        addChild(menu)
        addChild(play)
        addChild(replay)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func touchAt(_ point: CGPoint) {
        if menu.frame.contains(point) {
            let scene = StartScene(size: self.scene!.frame.size)
            self.scene!.view!.presentScene(scene, transition: SKTransition.flipVertical(withDuration: TimeInterval(1)))
            scene.adjustPosition(false, sizeChange: true)
        } else if play.frame.contains(point) {
            removeFromParent()
            game.quitPause()
            game.addChild(game.pause)
        } else if replay.frame.contains(point) {
            game.level.start(game.scene!.view!, transition: SKTransition.fade(with: SKColor.white, duration: 1))
        }
    }
}
