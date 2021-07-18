//
//  RandGameBonusLevel.swift
//  BreakBaloon
//
//  Created by Emil on 02/08/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit

class RandGameBonusLevel: RandGameLevel {
    let modifier: Double
    
    init(_ index: Int, modifier: Double) {
        self.modifier = modifier
        super.init(index)
    }
    
    override func start(_ view: SKView, transition: SKTransition = SKTransition.flipVertical(withDuration: 1)) {
        gamescene = RandGameScene(view: view, level: self)
        view.presentScene(gamescene!, transition: transition)
        gamescene!.addChild(RandGameBonusLevelInfoNode(level: self, scene: gamescene!))
    }
    
    override func end(_ missing: Int) {
        guard !status.finished else {
            super.end(missing)
            return
        }
        let xp = Double(max(0, numberOfBaloons - missing)) * modifier
        gamescene!.gvc.addXP(xp)
        let stars = missing == 0 ? 3 : missing <= maxMissingBaloonToWin / 2 ? 2 : 1
        status = RandGameLevelStatus.getFinished(stars: stars)
        save()
        unlockNextLevel()
        gamescene?.addChild(RandGameLevelEndNode(level: self, scene: gamescene!, stars: stars, xpBonus: Int(xp)))
    }
    
    override func createNode() -> RandGameLevelNode {
        RandGameBonusLevelNode(level: self)
    }
}
