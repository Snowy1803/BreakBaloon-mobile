//
//  RandGameBonusLevelNode.swift
//  BreakBaloon
//
//  Created by Emil on 02/08/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit

class RandGameBonusLevelNode: RandGameLevelNode {
    override func updateTexture() {
        texture = level.status == .unlocked ? SKTexture(imageNamed: "levelbuttonbg-bonus") : SKTexture(imageNamed: "levelbuttonbg-bonus-\(String(describing: level.status).lowercased())")
        level.save()
    }
}
