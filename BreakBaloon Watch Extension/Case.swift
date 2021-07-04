//
//  WatchCase.swift
//  BreakBaloon Watch Extension
//
//  Created by Emil Pedersen on 20/10/2019.
//  Copyright © 2019 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit

class Case: SKSpriteNode {
    let type: Int
    let index: Int
    var status: CaseStatus = .closed
    var breaked: Bool {
        return status != .closed
    }
    
    init(index: Int) {
        type = Int(arc4random_uniform(UInt32(6)))
        self.index = index
        let texture = SKTexture(imageNamed: "closed" + String(type))
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        blendMode = .replace
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func breakBaloon(_ winner: Bool) {
        status = winner ? .winnerOpened : .opened
        texture = SKTexture(imageNamed: "opened" + String(type))
        if UserDefaults.standard.bool(forKey: "extension.animation.enabled") {
            triggerAnimationExtension()
        }
    }
    
    func baloonBreaked() {}
    
    func triggerAnimationExtension() {
        let action = SKAction.run {
            self.animate([0: SKColor.red, 1: SKColor.yellow, 2: SKColor.blue, 3: SKColor(red: 191 / 255, green: 1, blue: 0, alpha: 1), 4: SKColor(red: 1, green: 191 / 255, blue: 191 / 255, alpha: 1), 5: SKColor(red: 0.5, green: 0, blue: 1, alpha: 1)][self.type])
        }
        run(SKAction.sequence([action, SKAction.wait(forDuration: 0.2), action, SKAction.wait(forDuration: 0.2), action, SKAction.wait(forDuration: 0.2), action, SKAction.wait(forDuration: 0.2), action]))
    }
    
    func animate(_ color: SKColor?) {
        for _ in 0 ..< arc4random_uniform(10) {
            let shape = SKShapeNode(circleOfRadius: CGFloat(arc4random_uniform(10) + 1) / 300.0)
            shape.position = CGPoint(x: (CGFloat(arc4random_uniform(75)) - 75.0 / 2) / 300.0, y: (CGFloat(arc4random_uniform(75)) - 75.0 / 2) / 300.0)
            shape.fillColor = color != nil ? color! : SKColor(red: CGFloat.random(in: 0 ..< 1), green: CGFloat.random(in: 0 ..< 1), blue: CGFloat.random(in: 0 ..< 1), alpha: 1)
            shape.strokeColor = SKColor.clear
            shape.zPosition = 1
            shape.run(SKAction.sequence([SKAction.wait(forDuration: 0.2), SKAction.removeFromParent()]))
            addChild(shape)
        }
    }
    
    enum CaseStatus: Int {
        case closed
        case opened
        case winnerOpened
    }
}
