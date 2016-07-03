//
//  Case.swift
//  BreakBaloon
//
//  Created by Emil on 20/06/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit

class Case:SKSpriteNode {
    var breaked:Bool = false
    let type:Int
    let index:Int
    
    init(index:Int) {
        type = Int(arc4random_uniform(6))
        self.index = index
        let texture = SKTexture(imageNamed: "closed" + String(type))
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func breakBaloon() {
        breaked = true
        texture = SKTexture(imageNamed: "opened" + String(type))
    }
}