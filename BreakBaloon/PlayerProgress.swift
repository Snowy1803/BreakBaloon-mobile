//
//  PlayerXP.swift
//  BreakBaloon
//
//  Created by Emil Pedersen on 05/07/2021.
//  Copyright © 2021 Snowy_1803. All rights reserved.
//

import Foundation
import GameKit

class PlayerProgress: Codable {
    static let savefile = FileSaveHelper(fileName: "progress", fileExtension: .json)
    static let current: PlayerProgress = {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(PlayerProgress.self, from: try savefile.getData())
        } catch {
            print("failed to read player progress file, falling back on user defaults", error)
            return PlayerProgress(loadFromUserDefaults: UserDefaults.standard)
        }
    }()
    
    private init(loadFromUserDefaults defaults: UserDefaults) {
        totalXP = Double(defaults.integer(forKey: "exp"))
        soloHighscore = defaults.integer(forKey: "highscore")
        timedHighscore = defaults.integer(forKey: "bestTimedScore")
        var randomLevelStatus: [RandGameLevelStatus] = []
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
        self.randomLevelStatus = randomLevelStatus
        save()
    }
    
    // MARK: Stored properties
    
    var totalXP: Double {
        didSet {
            save()
        }
    }
    
    var soloHighscore: Int {
        didSet {
            save()
        }
    }
    
    var timedHighscore: Int {
        didSet {
            save()
        }
    }
    
    var randomLevelStatus: [RandGameLevelStatus] {
        didSet {
            save()
        }
    }
    
    // MARK: Convenience computed properties
    
    var currentLevelFractional: Double {
        totalXP / 250 + 1
    }
    
    var currentLevel: Int {
        Int(currentLevelFractional)
    }
    
    var levelXP: Double {
        totalXP.truncatingRemainder(dividingBy: 250)
    }
    
    var levelProgression: Double {
        levelXP / 250
    }
    
    var gameCenterLevel: Int64 {
        Int64(currentLevelFractional * 1000)
    }
    
    var randomLevelStarCount: Int64 {
        randomLevelStatus.reduce(into: 0 as Int64) { result, current in
            result += Int64(current.stars)
        }
    }
    
    func save() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(self)
            try PlayerProgress.savefile.saveFile(data: data)
        } catch {
            print("Save failed!", error)
        }
    }
}

extension GKAchievement {
    static func unlock(id: String) {
        GKAchievement.loadAchievements { (achievements: [GKAchievement]?, error: Error?) in
            let achievement = achievements?.first(where: { $0.identifier == id }) ?? GKAchievement(identifier: id)
            
            achievement.showsCompletionBanner = true
            achievement.percentComplete = 100
            GKAchievement.report([achievement]) { error in
                if let error = error {
                    print(error)
                } else {
                    print("achievement submitted")
                }
            }
            
            if let error = error {
                print(error)
            }
        }
    }
}
