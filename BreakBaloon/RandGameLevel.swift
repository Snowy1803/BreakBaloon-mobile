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
    private static let levelValues:[(UInt, NSTimeInterval, NSTimeInterval, UInt, UInt)] = [
        /* 1 */     (10, 1.25, 4, 1, 2),
        /* 2 */     (10, 0.75, 4, 1, 2),
        /* 3 */     (30, 0.75, 3.5, 5, 3),
        /* 4 */     (25, 0.75, 3, 3, 3),
        /* 5 */     (35, 0.75, 2.5, 1, 3),
        /* 6 */     (35, 0.75, 2.25, 0, 3),
        /* 7 */     (40, 0.5, 2, 2, 4),
        /* 8 */     (40, 0.5, 2, 3, 3),
        /* 9 */     (40, 0.5, 1.5, 1, 3),
        /* 10 */    (75, 0.75, 2.5, 0, 3),
        /* 11 */    (10, 0.25, 2.5, 0, 1),
        /* 12 */    (10, 0, 2.5, 3, 1)
    ]
    
    static let levels:[RandGameLevel] = [RandGameLevel(0), RandGameLevel(1), RandGameLevel(2), RandGameLevel(3), RandGameLevel(4), RandGameLevel(5), RandGameLevel(6), RandGameLevel(7), RandGameLevel(8), RandGameLevel(9), RandGameLevel(10), RandGameLevel(11)]
    
    let index:Int
    var status:RandGameLevelStatus?
    var gamescene:RandGameScene?
    
    var level:(UInt, NSTimeInterval, NSTimeInterval, UInt, UInt) {
        get {
            return RandGameLevel.levelValues[index]
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
    
    private init(_ index:Int) {
        print("HEY \(index)")
        self.index = index
        self.status = .Locked
    }
    
    func start(view: SKView, transition: SKTransition = SKTransition.flipVerticalWithDuration(NSTimeInterval(1))) {
        gamescene = RandGameScene(view: view, numberOfBaloons: level.0, baloonTime: level.1, speed: level.2, maxBaloons: level.4, completion: end)
        gamescene!.pauseGame()
        view.presentScene(gamescene!, transition: transition);
        gamescene!.addChild(RandGameLevelInfoNode(level: self, scene: gamescene!))
    }
    
    func end(missing: Int) {
        gamescene?.addChild(RandGameLevelEndNode(level: self, scene: gamescene!))
        if missing <= Int(level.3) {
            status = .Finished
            save()
            if next != nil && (next!.status == .Unlockable || next!.status == .Locked) {
                next!.status = .Unlocked
                next!.save()
                if next!.next != nil && next!.next!.status == .Locked {
                    next!.next!.status = .Unlockable
                    next!.next!.save()
                }
            }
        }
    }
    
    func save() {
        NSUserDefaults.standardUserDefaults().setInteger(status!.rawValue, forKey: "rand.level.\(index)")
    }
    
    func open() {
        let data = NSUserDefaults.standardUserDefaults()
        if data.objectForKey("rand.level.\(index)") == nil {
            data.setInteger(RandGameLevelStatus.defaultValue(index, pre: precedent?.status).rawValue, forKey: "rand.level.\(index)")
        }
        self.status = RandGameLevelStatus(rawValue: data.integerForKey("rand.level.\(index)"))!
        save()
    }
    
    enum RandGameLevelStatus: Int {
        case Locked
        case Unlockable
        case Unlocked
        case Finished
        
        static func defaultValue(index: Int, pre: RandGameLevelStatus?) -> RandGameLevelStatus {
            if index == 0 {
                return .Unlocked
            } else if index == 1 {
                return .Unlockable
            } else if pre == .Finished {
                return .Unlocked
            } else if pre == .Unlocked {
                return .Unlockable
            }
            return .Locked
        }
        
        func isUnlocked() -> Bool {
            return self == .Unlocked || self == .Finished
        }
    }
}