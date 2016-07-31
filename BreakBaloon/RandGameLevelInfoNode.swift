//
//  RandGameLevelInfoNode.swift
//  BreakBaloon
//
//  Created by Emil on 30/07/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit

class RandGameLevelInfoNode: SKNode {
    let level:RandGameLevel
    
    init(level: RandGameLevel, scene: RandGameScene) {
        self.level = level
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
        let tbaloons = SKLabelNode(text: String(format: NSLocalizedString("gameinfo.baloons", comment: "Baloons: n"), level.level.0))
        tbaloons.position = CGPointMake(scene.frame.width / 2, scene.frame.height / 6 * 5 - 128)
        tbaloons.fontSize = 24
        tbaloons.fontColor = SKColor.blackColor()
        tbaloons.fontName = "HelveticaNeue-Bold"
        addChild(tbaloons)
        let tspeed = SKLabelNode(text: NSLocalizedString("gameinfo.speed.\(speedString())", comment: "Speed: s"))
        tspeed.position = CGPointMake(scene.frame.width / 2, scene.frame.height / 6 * 5 - 160)
        tspeed.fontSize = 24
        tspeed.fontColor = SKColor.blackColor()
        tspeed.fontName = "HelveticaNeue-Bold"
        addChild(tspeed)
        let treq = SKLabelNode(text: String(format: NSLocalizedString("gameinfo.requirePoints", comment: "n points for win"), level.level.0 - level.level.3))
        treq.position = CGPointMake(scene.frame.width / 2, scene.frame.height / 6 + 32)
        treq.fontSize = 24
        treq.fontColor = SKColor.blackColor()
        treq.fontName = "HelveticaNeue-Bold"
        addChild(treq)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func speedString() -> String {
        if level.level.1 > 1 && level.level.2 > 3 {
            return "low"
        } else if level.level.2 > 2 && level.level.1 > 0.5 {
            return "medium"
        } else if level.level.2 > 1 && level.level.1 > 0.25 {
            return "high"
        }
        return "extreme"
    }
}