//
//  PlayerXP.swift
//  BreakBaloon
//
//  Created by Emil Pedersen on 05/07/2021.
//  Copyright © 2021 Snowy_1803. All rights reserved.
//

import Foundation

enum PlayerXP {
    static var totalXP: Int {
        get {
            UserDefaults.standard.integer(forKey: "exp")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "exp")
        }
    }
    
    static var currentLevel: Int {
        totalXP / 250 + 1
    }
    
    static var levelXP: Int {
        totalXP % 250
    }
    
    static var levelProgression: Double {
        Double(levelXP) / 250
    }
    
    static var soloHighscore: Int {
        get {
            UserDefaults.standard.integer(forKey: "highscore")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "highscore")
        }
    }
    
    static var timedHighscore: Int {
        get {
            UserDefaults.standard.integer(forKey: "bestTimedScore")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "bestTimedScore")
        }
    }
    
    static subscript(statusForRandomLevel level: Int) -> RandGameLevelStatus {
        get {
            let data = UserDefaults.standard
            if data.object(forKey: "rand.level.\(level)") == nil {
                let previous = level == 0 ? nil : self[statusForRandomLevel: level - 1]
                return RandGameLevelStatus.defaultValue(level, pre: previous)
            }
            return RandGameLevelStatus(rawValue: data.integer(forKey: "rand.level.\(level)"))!
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "rand.level.\(level)")
        }
    }
}
