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
        let bonusXP: Int
        if !status.finished {
            let xp = Double(numberOfBaloons - missing) * (status.finished ? 1 : modifier)
            gamescene!.gvc.addXP(xp)
            bonusXP = Int(xp)
        } else {
            bonusXP = -1
        }
        
        let stars = missing == 0 ? 3 : (numberOfBaloons - maxMissingBaloonToWin) < gamescene!.points ? 2 : 1
        status = RandGameLevelStatus.getFinished(stars: stars)
        save()
        unlockNextLevel()
        gamescene?.addChild(RandGameLevelEndNode(level: self, scene: gamescene!, stars: stars, xpBonus: bonusXP))
    }
    
    override func createNode() -> RandGameLevelNode {
        RandGameBonusLevelNode(level: self)
    }
}
