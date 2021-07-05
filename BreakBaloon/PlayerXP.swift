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
        UserDefaults.standard.integer(forKey: "exp")
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
}
