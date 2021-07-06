//
//  Case.swift
//  BreakBaloon
//
//  Created by Emil on 20/06/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit

class Case: SKSpriteNode {
    let gvc: GameViewController
    let type: Int
    let index: Int
    var status: CaseStatus = .closed
    var breaked: Bool {
        status != .closed
    }
    
    init(gvc: GameViewController, index: Int) {
        type = Int.random(in: 0..<gvc.currentTheme.baloonCount)
        self.index = index
        self.gvc = gvc
        let texture = gvc.currentTheme.getBaloonTexture(status: status, type: type, fake: false)
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func breakBaloon(_ winner: Bool) {
        status = winner ? .winnerOpened : .opened
        texture = gvc.currentTheme.getBaloonTexture(case: self)
        if UserDefaults.standard.bool(forKey: "extension.animation.enabled") {
            triggerAnimationExtension()
        }
    }
    
    func baloonBreaked() {
        if let game = gvc.currentGame as? GameScene,
           game.gametype != .timed,
           UserDefaults.standard.bool(forKey: "extension.hintarrow.enabled") {
            showHintArrow(game: game)
        }
    }
    
    func triggerAnimationExtension() {
        let action = SKAction.run {
            self.animate(self.gvc.currentTheme.animationColor(type: self.type))
        }
        run(SKAction.sequence([action, SKAction.wait(forDuration: 0.2), action, SKAction.wait(forDuration: 0.2), action, SKAction.wait(forDuration: 0.2), action, SKAction.wait(forDuration: 0.2), action]))
    }
    
    func animate(_ color: SKColor?) {
        for _ in 0..<Int.random(in: 0..<10) {
            let shape = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...10))
            shape.position = CGPoint(x: CGFloat.random(in: -37...37), y: CGFloat.random(in: -37...37))
            shape.fillColor = color ?? SKColor(red: CGFloat.random(in: 0..<1), green: CGFloat.random(in: 0..<1), blue: CGFloat.random(in: 0..<1), alpha: 1)
            shape.strokeColor = SKColor.clear
            shape.zPosition = 1
            shape.run(SKAction.sequence([SKAction.wait(forDuration: 0.2), SKAction.removeFromParent()]))
            addChild(shape)
        }
    }
    
    func showHintArrow(game: GameScene) {
        let shape = SKShapeNode(path: polygon([(-15, 0), (-3, -15), (-3, -3), (15, -3), (15, 3), (-3, 3), (-3, 15)]))
        let deltaWinX = game.winCaseNumber % game.width - index % game.width
        let deltaWinY = game.winCaseNumber / game.height - index / game.height
        
        let theta = atan2(Double(-deltaWinY), Double(deltaWinX))
        
        shape.zRotation = CGFloat(theta + .pi)
        shape.fillColor = SKColor.blue
        shape.strokeColor = SKColor.clear
        shape.zPosition = 2
        shape.run(SKAction.sequence([SKAction.wait(forDuration: 0.4), SKAction.removeFromParent()]))
        addChild(shape)
    }
    
    func polygon(_ points: [(CGFloat, CGFloat)]) -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: points[0].0, y: points[0].1))
        for i in 1..<points.count {
            path.addLine(to: CGPoint(x: points[i].0, y: points[i].1))
        }
        path.addLine(to: CGPoint(x: points[0].0, y: points[0].1))
        return path
    }
    
    enum CaseStatus: Int {
        case closed
        case opened
        case winnerOpened
    }
}
