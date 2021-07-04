//
//  RandGameBonusLevel.swift
//  BreakBaloon
//
//  Created by Emil on 02/08/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit
private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (left?, right?):
        return left < right
    case (nil, _?):
        return true
    default:
        return false
    }
}

class RandGameBonusLevel: RandGameLevel {
    let modifier: Float
    
    init(_ index: Int, modifier: Float) {
        self.modifier = modifier
        super.init(index)
    }
    
    override func canPlay() -> Bool {
        // Can only play one time
        status.isUnlocked() && !status.isFinished()
    }
    
    override func start(_ view: SKView, transition: SKTransition = SKTransition.flipVertical(withDuration: 1)) {
        gamescene = RandGameScene(view: view, level: self)
        view.presentScene(gamescene!, transition: transition)
        gamescene!.addChild(RandGameBonusLevelInfoNode(level: self, scene: gamescene!))
    }
    
    override func end(_ missing: Int) {
        let xp = Int((Float(numberOfBaloons) - Float(missing)) * modifier)
        gamescene!.gvc.addXP(xp)
        
        let stars = missing == 0 ? 3 : (Int(numberOfBaloons) - Int(maxMissingBaloonToWin)) < gamescene?.points ? 2 : 1
        status = RandGameLevelStatus.getFinished(stars: stars)
        save()
        if next != nil, next!.status == .unlockable || next!.status == .locked {
            next!.status = .unlocked
            next!.save()
            if next!.next != nil, next!.next!.status == .locked {
                next!.next!.status = .unlockable
                next!.next!.save()
            }
        }
        gamescene?.addChild(RandGameLevelEndNode(level: self, scene: gamescene!, stars: stars, xpBonus: xp))
    }
    
    override func createNode() -> RandGameLevelNode {
        RandGameBonusLevelNode(level: self)
    }
}
