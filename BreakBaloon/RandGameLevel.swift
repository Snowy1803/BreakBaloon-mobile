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
    fileprivate static let levelValues:[(UInt, TimeInterval, TimeInterval, UInt, UInt, Float)] = [
        /* 1 */     (10, 1.25, 4, 2, 2, 0),
        /* 2 */     (10, 0.75, 4, 2, 2, 0),
        /* 3 */     (30, 0.75, 3.5, 5, 3, 0),
        /* 4 */     (25, 0.75, 3, 3, 3, 0),
        /* 5 */     (35, 0.75, 2.5, 1, 3, 0),
        /* 6 */     (35, 0.75, 2.25, 0, 3, 0),
        /* 7 */     (40, 0.5, 2, 2, 4, 0),
        /* 8 */     (40, 0.5, 2, 3, 3, 0),
        /* 9 */     (40, 0.5, 1.5, 1, 3, 0),
        /* 10 */    (75, 0.75, 2.5, 0, 3, 0),
        /* 11 */    (10, 0.25, 2.5, 0, 1, 0),
        /* 12 */    (10, 0, 2.5, 3, 1, 0),
        /* 13 */    (15, 0, 2, 5, 1, 0),
        /* 14 */    (100, 0.5, 2.5, 5, 3, 0),
        /* 15 */    (125, 0.5, 1.5, 10, 4, 0),
        /* B-16 */  (25, 0.25, 1.5, 25, 3, 0),
        /* 17 */    (30, 0.5, 2, 1, 1, 0.5),
        /* 18 */    (30, 0.35, 1.5, 0, 1, 0.35),
        /* 19 */    (45, 0.25, 1.5, 2, 2, 0.15),
        /* 20 */    (10, 0, 2.5, 1, 1, 0.35),
        /* 21 */    (30, 0.25, 2, 3, 3, 0.5),
        /* 22 */    (5, 0.25, 2, 0, 2, 0.9),
        /* 23 */    (15, 0.25, 1, 0, 10, 0.6),
        /* B-24 */  (20, 0.25, 1.5, 20, 4, 0.5),
    ]
    
    static let levels:[RandGameLevel] = [RandGameLevel(0), RandGameLevel(1), RandGameLevel(2), RandGameLevel(3), RandGameLevel(4), RandGameLevel(5), RandGameLevel(6), RandGameLevel(7), RandGameLevel(8), RandGameLevel(9), RandGameLevel(10), RandGameLevel(11), RandGameLevel(12), RandGameLevel(13), RandGameLevel(14), RandGameBonusLevel(15, modifier: 5), RandGameLevel(16), RandGameLevel(17), RandGameLevel(18), RandGameLevel(19), RandGameLevel(20), RandGameLevel(21), RandGameLevel(22), RandGameBonusLevel(23, modifier: 5)]
    
    let index:Int
    var status:RandGameLevelStatus
    var gamescene:RandGameScene?
    
    fileprivate var level:(UInt, TimeInterval, TimeInterval, UInt, UInt, Float) {
        get {
            return RandGameLevel.levelValues[index]
        }
    }
    
    var numberOfBaloons:UInt {
        get {
            return level.0
        }
    }
    
    var secondsBeforeBaloonVanish:TimeInterval {
        get {
            return level.1
        }
    }
    
    var maxSecondsBeforeNextBaloon:TimeInterval {
        get {
            return level.2
        }
    }
    
    var maxMissingBaloonToWin:UInt {
        get {
            return level.3
        }
    }
    
    var maxBaloonsAtSameTime:UInt {
        get {
            return level.4
        }
    }
    
    var fakeBaloonsRate:Float {
        get {
            return level.5
        }
    }
    
    var precedent: RandGameLevel? {
        get {
            return index > 0 ? RandGameLevel.levels[index - 1] : nil
        }
    }
    
    var next: RandGameLevel? {
        get {
            return index + 1 < RandGameLevel.levels.count ? RandGameLevel.levels[index + 1] : nil
        }
    }
    
    
    internal init(_ index:Int) {
        self.index = index
        self.status = .locked
    }
    
    func start(_ view: SKView, transition: SKTransition = SKTransition.flipVertical(withDuration: TimeInterval(1))) {
        gamescene = RandGameScene(view: view, level: self)
        view.presentScene(gamescene!, transition: transition);
        gamescene!.addChild(RandGameLevelInfoNode(level: self, scene: gamescene!))
    }
    
    func end(_ missing: Int) {
        var stars = 0
        if missing <= Int(maxMissingBaloonToWin) {
            stars = missing == 0 ? 3 : (Int(maxMissingBaloonToWin)) / 2 < missing ? 2 : 1
            if status.getStars() < stars {
                status = RandGameLevelStatus.getFinished(stars: stars)
            }
            save()
            if next != nil && (next!.status == .unlockable || next!.status == .locked) {
                next!.status = .unlocked
                next!.save()
                if next!.next != nil && next!.next!.status == .locked {
                    next!.next!.status = .unlockable
                    next!.next!.save()
                }
            }
        }
        gamescene?.addChild(RandGameLevelEndNode(level: self, scene: gamescene!, stars: stars))
    }
    
    func save() {
        UserDefaults.standard.set(status.rawValue, forKey: "rand.level.\(index)")
    }
    
    func open() {
        let data = UserDefaults.standard
        if data.object(forKey: "rand.level.\(index)") == nil {
            data.set(RandGameLevelStatus.defaultValue(index, pre: precedent?.status).rawValue, forKey: "rand.level.\(index)")
        }
        self.status = RandGameLevelStatus(rawValue: data.integer(forKey: "rand.level.\(index)"))!
        save()
    }
    
    func canPlay() -> Bool {
        return status.isUnlocked()
    }
    
    func createNode() -> RandGameLevelNode {
        return RandGameLevelNode(level: self)
    }
    
    enum RandGameLevelStatus: Int {
        case locked
        case unlockable
        case unlocked
        case finished1Star
        case finished2Star
        case finished3Star
        
        static func defaultValue(_ index: Int, pre: RandGameLevelStatus?) -> RandGameLevelStatus {
            if index == 0 {
                return .unlocked
            } else if index == 1 {
                return .unlockable
            } else if pre != nil && pre!.isFinished() {
                return .unlocked
            } else if pre == .unlocked {
                return .unlockable
            }
            return .locked
        }
        
        func isUnlocked() -> Bool {
            return self == .unlocked || self.isFinished()
        }
        
        
        func isFinished() -> Bool {
            return self == .finished1Star || self == .finished2Star || self == .finished3Star
        }
        
        func getStars() -> Int {
            if self == .finished1Star {
                return 1
            } else if self == .finished2Star {
                return 2
            } else if self == .finished3Star {
                return 3
            }
            return 0
        }
        
        static func getFinished(stars: Int) -> RandGameLevelStatus {
            if stars == 1 {
                return .finished1Star
            } else if stars == 2 {
                return .finished2Star
            } else if stars == 3 {
                return .finished3Star
            }
            return .unlocked
        }
    }
}
