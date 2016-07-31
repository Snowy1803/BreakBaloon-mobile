//
//  RandGameLevelInfoNode.swift
//  BreakBaloon
//
//  Created by Emil on 30/07/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit

class RandGameLevelEndNode: SKNode {
    let level:RandGameLevel
    let replay: SKSpriteNode
    let back: SKSpriteNode
    let next: SKSpriteNode?
    
    init(level: RandGameLevel, scene: RandGameScene) {
        let successful = scene.points >= Int(level.level.0 - level.level.3)
        self.level = level
        self.replay = SKSpriteNode(imageNamed: "levelreplay")
        self.back = SKSpriteNode(imageNamed: "levelback")
        if successful {
            self.next = SKSpriteNode(imageNamed: "levelnext")
        } else {
            self.next = nil
        }
        super.init()
        self.zPosition = 1000
        let rect = SKShapeNode(rect: CGRect(x: scene.frame.width / 6, y: scene.frame.height / 6, width: scene.frame.width / 1.5, height: scene.frame.height / 1.5))
        rect.fillColor = SKColor.lightGrayColor()
        addChild(rect)
        let tlevel = SKLabelNode(text: String(format: NSLocalizedString("gameinfo.level", comment: "Level n"), level.index + 1))
        tlevel.position = CGPointMake(scene.frame.width / 2, scene.frame.height / 6 * 5 - 32)
        tlevel.fontSize = 24
        tlevel.fontColor = SKColor.blackColor()
        tlevel.fontName = "Copperplate-Bold"
        addChild(tlevel)
        let tstatus = SKLabelNode(text: NSLocalizedString("gameinfo.end.\(successful ? "finished" : "failed")", comment: "Level finished"))
        tstatus.position = CGPointMake(scene.frame.width / 2, scene.frame.height / 6 * 5 - 128)
        tstatus.fontSize = 24
        tstatus.fontColor = successful ? SKColor.greenColor() : SKColor.redColor()
        tstatus.fontName = "Copperplate-Bold"
        addChild(tstatus)
        let tcomplete = SKLabelNode(text: String(format: NSLocalizedString("gameinfo.complete", comment: "complete: n / n"), scene.points, level.level.0 - level.level.3))
        tcomplete.position = CGPointMake(scene.frame.width / 2, scene.frame.height / 6 * 5 - 160)
        tcomplete.fontSize = 24
        tcomplete.fontColor = SKColor.blackColor()
        tcomplete.fontName = "HelveticaNeue-Bold"
        addChild(tcomplete)
        replay.position = CGPointMake(scene.frame.width / 2, scene.frame.height / 12 * 3)
        addChild(replay)
        back.position = CGPointMake(scene.frame.width / 2 - 80, scene.frame.height / 12 * 3)
        addChild(back)
        if successful {
            next!.position = CGPointMake(scene.frame.width / 2 + 80, scene.frame.height / 12 * 3)
            next!.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.resizeToWidth(80, height: 80, duration: 0.6), SKAction.resizeToWidth(64, height: 64, duration: 0.6)])))
            addChild(next!)
        } else {
            replay.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.resizeToWidth(80, height: 80, duration: 0.6), SKAction.resizeToWidth(64, height: 64, duration: 0.6)])))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func click(touch: CGPoint) {
        if back.containsPoint(touch) {
            backToMenu()
        } else if replay.containsPoint(touch) {
            setLevel(level, view: self.scene!.view!)
        } else if next != nil && next!.containsPoint(touch) {
            if level.next != nil {
                setLevel(level.next!, view: self.scene!.view!)
            } else {
                backToMenu()
            }
        }
    }
    
    func backToMenu() {
        let scene = StartScene(size: self.frame.size)
        self.scene!.view!.presentScene(scene, transition: SKTransition.flipVerticalWithDuration(NSTimeInterval(1)))
    }
    
    func setLevel(level: RandGameLevel, view: SKView) {
        level.gamescene = RandGameScene(view: view, numberOfBaloons: level.level.0, baloonTime: level.level.1, speed: level.level.2, maxBaloons: level.level.4, completion: level.end)
        level.gamescene!.pauseGame()
        view.presentScene(level.gamescene!, transition: SKTransition.fadeWithColor(SKColor.whiteColor(), duration: 1));
        level.gamescene!.addChild(RandGameLevelInfoNode(level: level, scene: level.gamescene!))
    }
}