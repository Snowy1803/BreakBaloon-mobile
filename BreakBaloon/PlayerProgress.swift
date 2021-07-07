//
//  PlayerXP.swift
//  BreakBaloon
//
//  Created by Emil Pedersen on 05/07/2021.
//  Copyright © 2021 Snowy_1803. All rights reserved.
//

import Foundation

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
        totalXP = defaults.integer(forKey: "exp")
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
    
    var totalXP: Int {
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
    
    var currentLevel: Int {
        totalXP / 250 + 1
    }
    
    var levelXP: Int {
        totalXP % 250
    }
    
    var levelProgression: Double {
        Double(levelXP) / 250
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
