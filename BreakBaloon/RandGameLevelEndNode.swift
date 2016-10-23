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
    let stars: SKSpriteNode?
    
    init(level: RandGameLevel, scene: RandGameScene, stars: Int, xpBonus: Int = -1) {
        let isBonusLevel = xpBonus > -1
        let successful = scene.points >= Int(level.numberOfBaloons - level.maxMissingBaloonToWin)
        self.level = level
        self.replay = SKSpriteNode(imageNamed: "levelreplay")
        self.back = SKSpriteNode(imageNamed: "levelback")
        if successful {
            self.next = SKSpriteNode(imageNamed: "levelnext")
            self.stars = SKSpriteNode(imageNamed: "levelstars\(stars)")
        } else {
            self.next = nil
            self.stars = nil
        }
        super.init()
        self.zPosition = 1000
        let rect = SKShapeNode(rect: CGRect(x: scene.frame.width / 6, y: scene.frame.height / 6, width: scene.frame.width / 1.5, height: scene.frame.height / 1.5))
        rect.fillColor = SKColor.lightGray
        addChild(rect)
        let tlevel = SKLabelNode(text: String(format: NSLocalizedString("gameinfo.level", comment: "Level n"), level.index + 1))
        tlevel.position = CGPoint(x: scene.frame.width / 2, y: scene.frame.height / 6 * 5 - 32)
        tlevel.fontSize = 24
        tlevel.fontColor = SKColor.black
        tlevel.fontName = "Copperplate-Bold"
        addChild(tlevel)
        let tstatus: SKLabelNode
        if isBonusLevel {
            tstatus = SKLabelNode(text: String(format: NSLocalizedString("gameinfo.end.bonus", comment: "Level finished with n xp"), xpBonus))
        } else {
            tstatus = SKLabelNode(text: NSLocalizedString("gameinfo.end.\(successful ? "finished" : "failed")", comment: "Level finished"))
        }
        tstatus.position = CGPoint(x: scene.frame.width / 2, y: scene.frame.height / 6 * 5 - 128)
        tstatus.fontSize = 24
        tstatus.fontColor = successful ? SKColor.green : SKColor.red
        tstatus.fontName = "Copperplate-Bold"
        addChild(tstatus)
        if !isBonusLevel {
            let tcomplete = SKLabelNode(text: String(format: NSLocalizedString("gameinfo.complete", comment: "complete: n / n"), scene.points, level.numberOfBaloons - level.maxMissingBaloonToWin))
            tcomplete.position = CGPoint(x: scene.frame.width / 2, y: scene.frame.height / 6 * 5 - 160)
            tcomplete.fontSize = 24
            tcomplete.fontColor = SKColor.black
            tcomplete.fontName = "HelveticaNeue-Bold"
            addChild(tcomplete)
            
            replay.position = CGPoint(x: scene.frame.width / 2, y: scene.frame.height / 12 * 3)
            addChild(replay)
        }
        
        back.position = CGPoint(x: scene.frame.width / 2 - 80, y: scene.frame.height / 12 * 3)
        addChild(back)
        if successful {
            if level.next != nil && level.next!.canPlay() {
                next!.position = CGPoint(x: scene.frame.width / 2 + 80, y: scene.frame.height / 12 * 3)
                next!.run(SKAction.repeatForever(SKAction.sequence([SKAction.resize(toWidth: 80, height: 80, duration: 0.6), SKAction.resize(toWidth: 64, height: 64, duration: 0.6)])))
                addChild(next!)
            }
            self.stars!.position = CGPoint(x: scene.frame.width / 2, y: scene.frame.height / 6 * 5 - 224)
            addChild(self.stars!)
            if stars < 3 {
                let remaining = SKLabelNode(text: String(format: NSLocalizedString("gameinfo.end.remaining\(Int(level.numberOfBaloons) - scene.points == 1 ? ".one" : "")", comment: "n remaining"), Int(level.numberOfBaloons) - scene.points))
                remaining.fontColor = SKColor.darkGray
                remaining.fontSize = 20
                remaining.fontName = "HelveticaNeue-Bold"
                remaining.position = CGPoint(x: scene.frame.width / 2, y: scene.frame.height / 6 * 5 - 275)
                addChild(remaining)
            }
        } else if !isBonusLevel {
            replay.run(SKAction.repeatForever(SKAction.sequence([SKAction.resize(toWidth: 80, height: 80, duration: 0.6), SKAction.resize(toWidth: 64, height: 64, duration: 0.6)])))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func click(_ touch: CGPoint) {
        if back.contains(touch) {
            backToMenu(self.scene!.view!)
        } else if replay.contains(touch) {
            setLevel(level, view: self.scene!.view!)
        } else if next != nil && next!.contains(touch) {
            if level.next != nil {
                setLevel(level.next!, view: self.scene!.view!)
            } else {
                backToMenu(self.scene!.view!)
            }
        }
    }
    
    func backToMenu(_ view: SKView) {
        let scene = StartScene(size: self.scene!.frame.size)
        view.presentScene(scene, transition: SKTransition.flipVertical(withDuration: TimeInterval(1)))
        scene.adjustPosition(false, sizeChange: true)
    }
    
    func setLevel(_ level: RandGameLevel, view: SKView) {
        if level.canPlay() {
            level.start(view, transition: SKTransition.fade(with: SKColor.white, duration: 1))
        }
    }
}
