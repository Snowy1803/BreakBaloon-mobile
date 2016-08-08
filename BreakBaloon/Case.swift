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
    let gvc:GameViewController
    let type:Int
    let index:Int
    var status:CaseStatus = .Closed
    var breaked:Bool {
        get {
            return status != .Closed
        }
    }
    
    init(gvc:GameViewController, index:Int) {
        type = Int(arc4random_uniform(UInt32(gvc.currentTheme.baloons)))
        self.index = index
        self.gvc = gvc
        let texture = gvc.currentTheme.getBaloonTexture(status: status, type: type)
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func breakBaloon(winner:Bool) {
        status = winner ? .WinnerOpened : .Opened
        texture = gvc.currentTheme.getBaloonTexture(self)
        if NSUserDefaults.standardUserDefaults().boolForKey("extension.animation.enabled") {
            triggerAnimationExtension()
        }
    }
    
    func triggerAnimationExtension() {
        let action = SKAction.runBlock({
            self.animate(self.gvc.currentTheme.animationColor == nil ? nil : self.gvc.currentTheme.animationColor![self.type])
        })
        runAction(SKAction.sequence([action, SKAction.waitForDuration(NSTimeInterval(0.2)), action, SKAction.waitForDuration(NSTimeInterval(0.2)), action, SKAction.waitForDuration(NSTimeInterval(0.2)), action, SKAction.waitForDuration(NSTimeInterval(0.2)), action]))
    }
    
    func animate(color: SKColor?) {
        for _ in 0..<arc4random_uniform(10) {
            let shape = SKShapeNode(circleOfRadius: CGFloat(arc4random_uniform(10) + 1))
            shape.position = CGPointMake(CGFloat(arc4random_uniform(75)) - 75/2, CGFloat(arc4random_uniform(75)) - 75/2)
            shape.fillColor = color != nil ? color! : SKColor(red: randomFloat(), green: randomFloat(), blue: randomFloat(), alpha: 1)
            shape.strokeColor = SKColor.clearColor()
            shape.zPosition = 1
            shape.runAction(SKAction.sequence([SKAction.waitForDuration(0.2), SKAction.removeFromParent()]))
            addChild(shape)
        }
    }
    
    func randomFloat() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX))
    }
    
    enum CaseStatus: Int {
        case Closed
        case Opened
        case WinnerOpened
    }
}