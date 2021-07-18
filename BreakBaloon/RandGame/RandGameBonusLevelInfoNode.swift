//
//  RandGameLevelInfoNode.swift
//  BreakBaloon
//
//  Created by Emil on 30/07/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit

class RandGameBonusLevelInfoNode: RandGameLevelInfoNode {
    init(level: RandGameBonusLevel, scene: RandGameScene) {
        super.init(level: level, scene: scene)
        tlevel.fontColor = SKColor(red: 1, green: 192 / 255, blue: 0, alpha: 1)
        treq.text = level.status.finished ? NSLocalizedString("gameinfo.bonus.replay", comment: "Play this bonus level again to get more stars") : NSLocalizedString("gameinfo.bonus.extraxp", comment: "Bonus level: Extra XP")
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
