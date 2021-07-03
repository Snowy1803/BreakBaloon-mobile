//
//  RandGameLevelInfoNode.swift
//  BreakBaloon
//
//  Created by Emil on 30/07/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit

class RandGameBonusLevelInfoNode: RandGameLevelInfoNode {
    init(level: RandGameBonusLevel, scene: RandGameScene) {
        super.init(level: level, scene: scene)
        removeAllChildren()
        if !level.canPlay() {
            _ = scene.gvc.getNil()! // CRASH
        }
        self.zPosition = 1000
        let rect = SKShapeNode(rect: CGRect(x: scene.frame.width / 6, y: scene.frame.height / 6, width: scene.frame.width / 1.5, height: scene.frame.height / 1.5))
        rect.fillColor = SKColor.lightGray
        addChild(rect)
        let tlevel = SKLabelNode(text: String(format: NSLocalizedString("gameinfo.level", comment: "Level n"), level.index + 1))
        tlevel.position = CGPoint(x: scene.frame.width / 2, y: scene.frame.height / 6 * 5 - 32)
        tlevel.fontSize = 24
        tlevel.fontColor = SKColor(red: 1, green: 192/255, blue: 0, alpha: 1)
        tlevel.fontName = "Copperplate-Bold"
        addChild(tlevel)
        let tbonus = SKLabelNode(text: String(format: NSLocalizedString("gameinfo.bonus", comment: "Bonus level"), level.numberOfBaloons))
        tbonus.position = CGPoint(x: scene.frame.width / 2, y: scene.frame.height / 6 * 5 - 64)
        tbonus.fontSize = 24
        tbonus.fontColor = SKColor.black
        tbonus.fontName = "Copperplate-Bold"
        addChild(tbonus)
        let tbaloons = SKLabelNode(text: String(format: NSLocalizedString("gameinfo.baloons", comment: "Baloons: n"), level.numberOfBaloons))
        tbaloons.position = CGPoint(x: scene.frame.width / 2, y: scene.frame.height / 6 * 5 - 128)
        tbaloons.fontSize = 24
        tbaloons.fontColor = SKColor.black
        tbaloons.fontName = "HelveticaNeue-Bold"
        addChild(tbaloons)
        let tspeed = SKLabelNode(text: NSLocalizedString("gameinfo.speed.\(speedString())", comment: "Speed: s"))
        tspeed.position = CGPoint(x: scene.frame.width / 2, y: scene.frame.height / 6 * 5 - 160)
        tspeed.fontSize = 24
        tspeed.fontColor = SKColor.black
        tspeed.fontName = "HelveticaNeue-Bold"
        addChild(tspeed)
        let treq = SKLabelNode(text: String(format: NSLocalizedString("gameinfo.requirePoints", comment: "n points for win"), level.numberOfBaloons - level.maxMissingBaloonToWin))
        treq.position = CGPoint(x: scene.frame.width / 2, y: scene.frame.height / 6 + 32)
        treq.fontSize = 24
        treq.fontColor = SKColor.black
        treq.fontName = "HelveticaNeue-Bold"
        addChild(treq)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
