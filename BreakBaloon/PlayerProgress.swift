//
//  PlayerXP.swift
//  BreakBaloon
//
//  Created by Emil Pedersen on 05/07/2021.
//  Copyright © 2021 Snowy_1803. All rights reserved.
//

import Foundation

class PlayerProgress {
    static let current = PlayerProgress(loadFromUserDefaults: UserDefaults.standard)
    
    init(loadFromUserDefaults defaults: UserDefaults) {
        totalXP = defaults.integer(forKey: "exp")
        soloHighscore = defaults.integer(forKey: "highscore")
        timedHighscore = defaults.integer(forKey: "bestTimedScore")
        randomLevelStatus = []
        let levels = RandGameLevel.levels.count
        randomLevelStatus.reserveCapacity(levels)
        var previous: RandGameLevelStatus?
        for level in 0..<levels {
            let status: RandGameLevelStatus
            if defaults.object(forKey: "rand.level.\(level)") == nil { // nil, use default
                status = RandGameLevelStatus.defaultValue(level, pre: previous)
            } else {
                status = RandGameLevelStatus(rawValue: defaults.integer(forKey: "rand.level.\(level)"))!
            }
            randomLevelStatus.append(status)
            previous = status
        }
    }
    
    // MARK: Stored properties
    
    var totalXP: Int {
        didSet {
            UserDefaults.standard.set(totalXP, forKey: "exp")
        }
    }
    
    var soloHighscore: Int {
        didSet {
            UserDefaults.standard.set(soloHighscore, forKey: "highscore")
        }
    }
    
    var timedHighscore: Int {
        didSet {
            UserDefaults.standard.set(timedHighscore, forKey: "bestTimedScore")
        }
    }
    
    private(set) var randomLevelStatus: [RandGameLevelStatus]
    
    // MARK: Convenience computed properties
    
    var currentLevel: Int {
        totalXP / 250 + 1
    }
    
    var levelXP: Int {
        totalXP % 250
    }
    
    var levelProgression: Double {
        Double(levelXP) / 250
    }
    
    subscript(statusForRandomLevel level: Int) -> RandGameLevelStatus {
        get {
            randomLevelStatus[level]
        }
        set {
            randomLevelStatus[level] = newValue
            UserDefaults.standard.set(newValue.rawValue, forKey: "rand.level.\(level)")
        }
    }
}
