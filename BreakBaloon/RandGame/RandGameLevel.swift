//
//  RandGameLevel.swift
//  BreakBaloon
//
//  Created by Emil on 30/07/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit

class RandGameLevel {
    // swiftlint:disable:next large_tuple
    fileprivate static let levelValues: [(Int, TimeInterval, TimeInterval, Int, Int, Float)] = [
        /* 1 */ (10, 1.25, 4, 2, 2, 0),
        /* 2 */ (10, 0.75, 4, 2, 2, 0),
        /* 3 */ (30, 0.75, 3.5, 5, 3, 0),
        /* 4 */ (25, 0.75, 3, 3, 3, 0),
        /* 5 */ (35, 0.75, 2.5, 1, 3, 0),
        /* 6 */ (35, 0.75, 2.25, 0, 3, 0),
        /* 7 */ (40, 0.5, 2, 2, 4, 0),
        /* 8 */ (40, 0.5, 2, 3, 3, 0),
        /* 9 */ (40, 0.5, 1.5, 1, 3, 0),
        /* 10 */ (75, 0.75, 2.5, 0, 3, 0),
        /* 11 */ (10, 0.25, 2.5, 0, 1, 0),
        /* 12 */ (10, 0, 2.5, 3, 1, 0),
        /* 13 */ (15, 0, 2, 5, 1, 0),
        /* 14 */ (100, 0.5, 2.5, 5, 3, 0),
        /* 15 */ (125, 0.5, 1.5, 10, 4, 0),
        /* B-16 */ (25, 0.25, 1.5, 25, 3, 0),
        /* 17 */ (30, 0.5, 2, 1, 1, 0.5),
        /* 18 */ (30, 0.35, 1.5, 0, 1, 0.35),
        /* 19 */ (45, 0.25, 1.5, 2, 2, 0.15),
        /* 20 */ (10, 0, 2.5, 1, 1, 0.35),
        /* 21 */ (30, 0.25, 2, 3, 3, 0.5),
        /* 22 */ (5, 0.25, 2, 0, 2, 0.9),
        /* 23 */ (15, 0.25, 1, 0, 10, 0.6),
        /* B-24 */ (20, 0.25, 1.5, 20, 4, 0.5),
    ]
    
    static let levels: [RandGameLevel] = [RandGameLevel(0), RandGameLevel(1), RandGameLevel(2), RandGameLevel(3), RandGameLevel(4), RandGameLevel(5), RandGameLevel(6), RandGameLevel(7), RandGameLevel(8), RandGameLevel(9), RandGameLevel(10), RandGameLevel(11), RandGameLevel(12), RandGameLevel(13), RandGameLevel(14), RandGameBonusLevel(15, modifier: 5), RandGameLevel(16), RandGameLevel(17), RandGameLevel(18), RandGameLevel(19), RandGameLevel(20), RandGameLevel(21), RandGameLevel(22), RandGameBonusLevel(23, modifier: 5)]
    
    let index: Int
    var status: RandGameLevelStatus
    var gamescene: RandGameScene?
    
    // swiftlint:disable:next large_tuple
    private var level: (Int, TimeInterval, TimeInterval, Int, Int, Float) {
        return RandGameLevel.levelValues[index]
    }
    
    var numberOfBaloons: Int {
        level.0
    }
    
    var secondsBeforeBaloonVanish: TimeInterval {
        level.1
    }
    
    var maxSecondsBeforeNextBaloon: TimeInterval {
        level.2
    }
    
    var maxMissingBaloonToWin: Int {
        level.3
    }
    
    var maxBaloonsAtSameTime: Int {
        level.4
    }
    
    var fakeBaloonsRate: Float {
        level.5
    }
    
    var precedent: RandGameLevel? {
        index > 0 ? RandGameLevel.levels[index - 1] : nil
    }
    
    var next: RandGameLevel? {
        index + 1 < RandGameLevel.levels.count ? RandGameLevel.levels[index + 1] : nil
    }
    
    internal init(_ index: Int) {
        self.index = index
        status = .locked
    }
    
    func start(_ view: SKView, transition: SKTransition = SKTransition.flipVertical(withDuration: 1)) {
        gamescene = RandGameScene(view: view, level: self)
        view.presentScene(gamescene!, transition: transition)
        gamescene!.addChild(RandGameLevelInfoNode(level: self, scene: gamescene!))
    }
    
    func end(_ missing: Int) {
        var stars = 0
        if missing <= maxMissingBaloonToWin {
            stars = missing == 0 ? 3 : maxMissingBaloonToWin / 2 < missing ? 2 : 1
            if status.stars < stars {
                status = RandGameLevelStatus.getFinished(stars: stars)
            }
            save()
            if next != nil, next!.status == .unlockable || next!.status == .locked {
                next!.status = .unlocked
                next!.save()
                if next!.next != nil, next!.next!.status == .locked {
                    next!.next!.status = .unlockable
                    next!.next!.save()
                }
            }
        }
        gamescene?.addChild(RandGameLevelEndNode(level: self, scene: gamescene!, stars: stars))
    }
    
    func save() {
        PlayerProgress.current.randomLevelStatus[index] = status
    }
    
    func load() {
        status = PlayerProgress.current.randomLevelStatus[index]
    }
    
    var playable: Bool {
        status.unlocked
    }
    
    func createNode() -> RandGameLevelNode {
        RandGameLevelNode(level: self)
    }
}
