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
    let level: RandGameLevel
    
    init(level: RandGameLevel, scene: RandGameScene) {
        self.level = level
        super.init()
        zPosition = 1000
        let rect = SKShapeNode(rect: CGRect(x: scene.frame.width / 6, y: scene.frame.height / 6, width: scene.frame.width / 1.5, height: scene.frame.height / 1.5))
        rect.fillColor = SKColor.lightGray
        addChild(rect)
        let tlevel = SKLabelNode(text: String(format: NSLocalizedString("gameinfo.level", comment: "Level n"), level.index + 1))
        tlevel.position = CGPoint(x: scene.frame.width / 2, y: scene.frame.height / 6 * 5 - 32)
        tlevel.fontSize = 24
        tlevel.fontColor = SKColor.black
        tlevel.fontName = "Copperplate-Bold"
        addChild(tlevel)
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
        if level.fakeBaloonsRate > 0 {
            let tfakeRate = SKLabelNode(text: NSLocalizedString("gameinfo.fakeBaloonRate.\(fakeBaloonRateString())", comment: "Fake Baloon Rate: s"))
            tfakeRate.position = CGPoint(x: scene.frame.width / 2, y: scene.frame.height / 6 * 5 - 192)
            tfakeRate.fontSize = 24
            tfakeRate.fontColor = SKColor.black
            tfakeRate.fontName = "HelveticaNeue-Bold"
            addChild(tfakeRate)
        }
        let treq = SKLabelNode(text: String(format: NSLocalizedString("gameinfo.requirePoints", comment: "n points for win"), level.numberOfBaloons - level.maxMissingBaloonToWin))
        treq.position = CGPoint(x: scene.frame.width / 2, y: scene.frame.height / 6 + 32)
        treq.fontSize = 24
        treq.fontColor = SKColor.black
        treq.fontName = "HelveticaNeue-Bold"
        addChild(treq)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func speedString() -> String {
        if level.secondsBeforeBaloonVanish > 1, level.maxSecondsBeforeNextBaloon > 3 {
            return "low"
        } else if level.maxSecondsBeforeNextBaloon > 2, level.secondsBeforeBaloonVanish > 0.5 {
            return "medium"
        } else if level.maxSecondsBeforeNextBaloon > 1, level.secondsBeforeBaloonVanish > 0.25 {
            return "high"
        }
        return "extreme"
    }
    
    func fakeBaloonRateString() -> String {
        if level.fakeBaloonsRate <= 0.25 {
            return "low"
        } else if level.fakeBaloonsRate <= 0.5 {
            return "medium"
        } else if level.fakeBaloonsRate <= 0.75 {
            return "high"
        }
        return "extreme"
    }
}
