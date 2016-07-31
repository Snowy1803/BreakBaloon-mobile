//
//  RandGameLevel.swift
//  BreakBaloon
//
//  Created by Emil on 30/07/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit

class RandGameLevel: SKSpriteNode {
    static let levels:[(UInt, NSTimeInterval, NSTimeInterval, UInt)] = [(10, 1.25, 4, 1), (10, 0.75, 4, 1), (30, 0.75, 3.5, 5), (25, 0.75, 3, 3), (35, 0.75, 2.5, 1)]
    
    var next:RandGameLevel?
    let index:Int
    let level:(UInt, NSTimeInterval, NSTimeInterval, UInt)
    var realPosition:CGPoint = CGPointZero
    var status:RandGameLevelStatus
    
    init(index:Int, level:(UInt, NSTimeInterval, NSTimeInterval, UInt)) {
        self.index = index
        self.level = level
        
        let data = NSUserDefaults.standardUserDefaults()
        if data.objectForKey("rand.level.\(index)") == nil {
            data.setInteger(RandGameLevelStatus.defaultValue(index).rawValue, forKey: "rand.level.\(index)")
        }
        self.status = RandGameLevelStatus(rawValue: data.integerForKey("rand.level.\(index)"))!
        
        let texture = SKTexture(imageNamed: "levelbuttonbg")
        super.init(texture: texture, color: SKColor.whiteColor(), size: texture.size())
        updateTexture()
        
        let label = SKLabelNode(text: "\(index + 1)")
        label.fontColor = SKColor.darkGrayColor()
        label.fontSize = 48
        label.fontName = "AppleSDGothicNeo-SemiBold"
        label.position = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame) - 16)
        label.zPosition = 1
        
        addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func click(view: SKView) {
        if status != .Locked {
            if status == .Unlockable {
                // TODO Display AD to unlock
            } else {
                start(view)
            }
        }
    }
    
    private func start(view: SKView) {
        let scene = RandGameScene(view: view, numberOfBaloons: level.0, baloonTime: level.1, speed: level.2, completion: end)
        scene.pauseGame()
        view.presentScene(scene, transition: SKTransition.flipVerticalWithDuration(NSTimeInterval(1)));
        scene.addChild(RandGameLevelInfoNode(level: self, scene: scene))
    }
    
    private func end(missing: UInt) {
        if missing <= level.3 {
            status = .Finished
            updateTexture()
            if next != nil && (next!.status == .Unlockable || next!.status == .Locked) {
                next!.status = .Unlocked
                next!.updateTexture()
                print("Unlocked level \(next!.index)")
                if next!.next != nil && next!.next!.status == .Locked {
                    next!.next!.status = .Unlockable
                    next!.next!.updateTexture()
                }
            }
        }
    }
    
    func updateTexture() {
        self.texture = status == .Unlocked ? SKTexture(imageNamed: "levelbuttonbg") : SKTexture(imageNamed: "levelbuttonbg-\(String(status).lowercaseString)")
        NSUserDefaults.standardUserDefaults().setInteger(status.rawValue, forKey: "rand.level.\(index)")
    }
    
    enum RandGameLevelStatus: Int {
        case Locked
        case Unlockable
        case Unlocked
        case Finished
        
        static func defaultValue(index:Int) -> RandGameLevelStatus {
            if index == 0 {
                return .Unlocked
            } else if index == 1 {
                return .Unlockable
            }
            return .Locked
        }
    }
}