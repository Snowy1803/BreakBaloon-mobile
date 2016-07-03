//
//  ImportMusic.swift
//  BreakBaloon
//
//  Created by Emil on 30/06/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit

class ImportMusic: SKSpriteNode {
    init() {
        let texture = SKTexture(imageNamed: "import")
        super.init(texture: texture, color: SKColor.clearColor(), size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}