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
    let level:RandGameLevel
    var realPosition:CGPoint = CGPointZero
    
    init(level: RandGameLevel) {
        self.level = level
        
        let texture = SKTexture(imageNamed: "levelbuttonbg")
        super.init(texture: texture, color: SKColor.whiteColor(), size: texture.size())
        updateTexture()
        
        let label = SKLabelNode(text: "\(level.index + 1)")
        label.fontColor = SKColor.darkGrayColor()
        label.fontSize = 48
        label.fontName = "AppleSDGothicNeo-SemiBold"
        label.position = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame) - 16)
        label.zPosition = 1
        
        addChild(label)
    }
    
    convenience init(index: Int) {
        self.init(level: RandGameLevel.levels[index])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func click(view: SKView, transition: SKTransition = SKTransition.flipVerticalWithDuration(NSTimeInterval(1))) {
        if level.status != .Locked {
            if level.status == .Unlockable {
                // TODO Display AD to unlock
            } else if level.canPlay() {
                level.start(view, transition: transition)
            }
        }
    }
    
    func updateTexture() {
        self.texture = level.status == .Unlocked ? SKTexture(imageNamed: "levelbuttonbg") : SKTexture(imageNamed: "levelbuttonbg-\(String(level.status).lowercaseString)")
        level.save()
    }
}