//
//  GameScene.swift
//  BreakBaloon Watch Extension
//
//  Created by Emil on 06/10/2019.
//  Copyright © 2019 Snowy_1803. All rights reserved.
//

import SpriteKit
import WatchConnectivity
import WatchKit

class WatchGameScene: SKScene {
    var cases: [Case]
    let width = 3, height = 3
    var winCaseNumber: Int = -1
    var points: Int = 0
    
    var controller: InterfaceController!
    
    override init() {
        cases = []
        cases.reserveCapacity(width * height)
        super.init()
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize) {
        cases = []
        cases.reserveCapacity(width * height)
        super.init(size: size)
    }
    
    func construct() {
        backgroundColor = .white
        let baloonSize = Case.baloonSize
        print("construct")
        for i in 0..<(width * height) {
            let theCase = Case(index: i)
            theCase.position = CGPoint(x: (CGFloat(i % width) + 0.5) * baloonSize + size.width / 8, y: (CGFloat(i / width) + 0.5) * baloonSize + size.height / 8)
            theCase.zPosition = 1
            theCase.size = CGSize(width: baloonSize, height: baloonSize)
            addChild(theCase)
            cases.append(theCase)
        }
        points = 0
        winCaseNumber = Int.random(in: 0..<(width * height))
    }
    
    override func sceneDidLoad() {
        construct()
    }
    
    func breakBaloon(_ index: Int, touch: CGPoint) {
        print("bb", index)
        let touched = cases[index]
        guard !touched.breaked else {
            return
        }
        touched.breakBaloon(index == winCaseNumber)
        var gameEnded = false
        if index == winCaseNumber {
            points += 1
            WKInterfaceDevice.current().play(.success)
            let plus = SKLabelNode(text: "+ 1")
            plus.fontColor = SKColor.blue
            plus.fontName = "HelveticaNeue-Bold"
            plus.fontSize = 20
            plus.setScale(0.005)
            plus.position = touch
            plus.zPosition = 3
            addChild(plus)
            print(plus, plus.frame)
            plus.run(SKAction.sequence([SKAction.wait(forDuration: 5), SKAction.removeFromParent()]))
            var unbreakedIndices: [Int] = []
            for (index, aCase) in cases.enumerated() where !aCase.breaked {
                unbreakedIndices.append(index)
            }
            if let randomElement = unbreakedIndices.randomElement() {
                winCaseNumber = randomElement
            } else { // nothing left
                gameEnd()
                gameEnded = true
            }
        }
        
        if !gameEnded {
            touched.baloonBreaked()
        }
    }
    
    func touchBegan(_ recognizer: WKLongPressGestureRecognizer) {
        let location = recognizer.locationInObject()
        let screenBounds = WKInterfaceDevice.current().screenBounds
        let newX = (location.x / screenBounds.width) * size.width
        let newY = -(location.y / screenBounds.height - 1) * size.height
        let point = CGPoint(x: newX, y: newY)
        if let touched = atPoint(point) as? Case {
            breakBaloon(touched.index, touch: point)
        }
    }
    
    func gameEnd() {
        let newRecord = UserDefaults.standard.integer(forKey: "highscore") < points
        let str = points == 1 ? NSLocalizedString("game.points.one", comment: "User got 1 point") : NSLocalizedString("game.points", comment: "User got a given number of points")
        let label = SKLabelNode(text: String(format: str, points))
        label.fontColor = SKColor.orange
        label.fontName = "HelveticaNeue-Bold"
        label.fontSize = 30
        label.setScale(0.005)
        label.zPosition = 1000
        label.position = CGPoint(x: frame.midX, y: frame.midY)
        print(label)
        addChild(label)
        
        label.run(SKAction.sequence([SKAction.wait(forDuration: 1), SKAction.run {
            label.fontColor = SKColor.black
            if newRecord {
                label.text = NSLocalizedString("game.highscore", comment: "User increased their watchOS high score")
            }
        }, SKAction.wait(forDuration: newRecord ? 1.5 : 0.5), SKAction.run {
            self.cases.removeAll()
            self.removeAllChildren()
            self.construct()
        }]))
        
        // highscore
        let data = UserDefaults.standard
        if data.integer(forKey: "highscore") < points {
            data.set(points, forKey: "highscore")
        }
        // xp
        let oldXP = UserDefaults.standard.integer(forKey: "exp")
        // modifier(level: 1) = 3.25, converges slowly towards 1
        let levelModifier = 9 / Double(oldXP / 250 + 4) + 1
        // modifier(size: 3*3) = 3
        // number of baloons count, but number of games too, by making it degressive
        let sizeModifier = sqrt(Double(width * height))
        let addedXP = Int(2 * levelModifier * sizeModifier)
        addXP(oldXP, addedXP)
        
        // xp animation
        let level = SKSpriteNode(imageNamed: "level")
        level.position = CGPoint(x: 0.25, y: 0.2)
        level.zPosition = 500
        level.size = CGSize(width: 0.2, height: 0.2)
        addChild(level)
        let tlevel = SKLabelNode(text: "\(oldXP / 250 + 1)")
        tlevel.position = CGPoint(x: 0.25, y: 0.15)
        tlevel.fontName = "AppleSDGothicNeo-Bold"
        tlevel.fontSize = 20
        tlevel.fontColor = SKColor.white
        tlevel.setScale(0.005)
        tlevel.zPosition = 501
        addChild(tlevel)
        let progressTotal = SKSpriteNode(color: .gray, size: CGSize(width: 0.5, height: 0.05))
        progressTotal.position = CGPoint(x: 0.55, y: 0.2)
        progressTotal.zPosition = 498
        addChild(progressTotal)
        let progress = SKSpriteNode(color: .blue, size: CGSize(width: CGFloat(oldXP % 250) / 500, height: 0.05))
        progress.position = CGPoint(x: 0.3, y: 0.2)
        progress.anchorPoint = CGPoint(x: 0, y: 0.5)
        progress.zPosition = 499
        addChild(progress)
        progress.run(SKAction.resize(toWidth: CGFloat((oldXP + addedXP) % 250) / 500, duration: 1))
        tlevel.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.run {
            tlevel.text = "\((oldXP + addedXP) / 250 + 1)"
        }]))
    }
    
    func addXP(_ oldXP: Int, _ xp: Int) {
        let levelBefore = (oldXP / 250 + 1)
        UserDefaults.standard.set(oldXP + xp, forKey: "exp")
        print("Added \(xp) XP")
        if levelBefore < ((oldXP + xp) / 250 + 1) {
            // Level up
        }
        print("XP:", oldXP + xp)
        WCSession.default.transferUserInfo(["exp": oldXP + xp])
    }
    
    override func update(_: TimeInterval) {
        // Called before each frame is rendered
    }
}
