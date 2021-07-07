//
//  RandGameLevelStatus.swift
//  BreakBaloon
//
//  Created by Emil Pedersen on 07/07/2021.
//  Copyright © 2021 Snowy_1803. All rights reserved.
//

import Foundation

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
        } else if pre?.finished == true {
            return .unlocked
        } else if pre == .unlocked {
            return .unlockable
        }
        return .locked
    }
    
    var unlocked: Bool {
        switch self {
        case .locked, .unlockable:
            return false
        case .unlocked, .finished1Star, .finished2Star, .finished3Star:
            return true
        }
    }
    
    var finished: Bool {
        switch self {
        case .locked, .unlockable, .unlocked:
            return false
        case .finished1Star, .finished2Star, .finished3Star:
            return true
        }
    }
    
    var stars: Int {
        switch self {
        case .locked, .unlockable, .unlocked:
            return 0
        case .finished1Star:
            return 1
        case .finished2Star:
            return 2
        case .finished3Star:
            return 3
        }
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
