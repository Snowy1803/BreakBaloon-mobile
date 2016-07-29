//
//  RandGameScene.swift
//  BreakBaloon
//
//  Created by Emil on 29/07/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit

class RandGameScene: AbstractGameScene {
    static let REQUIREMENT = 6
    
    init(view: SKView) {
        super.init(view: view, gametype: StartScene.GAMETYPE_RAND)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}