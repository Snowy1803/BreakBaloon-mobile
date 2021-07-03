//
//  RandGameLevel.swift
//  BreakBaloon
//
//  Created by Emil on 30/07/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit

class RandGameLevelNode: SKSpriteNode {
    let level: RandGameLevel
    var realPosition = CGPoint.zero
    
    init(level: RandGameLevel) {
        self.level = level
        
        let texture = SKTexture(imageNamed: "levelbuttonbg")
        super.init(texture: texture, color: SKColor.white, size: texture.size())
        updateTexture()
        
        let label = SKLabelNode(text: "\(level.index + 1)")
        label.fontColor = SKColor.darkGray
        label.fontSize = 48
        label.fontName = "AppleSDGothicNeo-SemiBold"
        label.position = CGPoint(x: frame.midX, y: frame.midY - 16)
        label.zPosition = 1
        
        addChild(label)
    }
    
    convenience init(index: Int) {
        self.init(level: RandGameLevel.levels[index])
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func click(_ view: SKView, transition: SKTransition = SKTransition.flipVertical(withDuration: TimeInterval(1))) {
        if level.status != .locked {
            if level.status == .unlockable {
                // TODO: Display AD to unlock
            } else if level.canPlay() {
                level.start(view, transition: transition)
            }
        }
    }
    
    func updateTexture() {
        texture = level.status == .unlocked ? SKTexture(imageNamed: "levelbuttonbg") : SKTexture(imageNamed: "levelbuttonbg-\(String(describing: level.status).lowercased())")
        level.save()
    }
}
