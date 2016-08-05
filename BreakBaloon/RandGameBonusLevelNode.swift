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
        self.texture = level.status == .Unlocked ? SKTexture(imageNamed: "levelbuttonbg-bonus") : SKTexture(imageNamed: "levelbuttonbg-bonus-\(String(level.status).lowercaseString)")
        level.save()
    }
}