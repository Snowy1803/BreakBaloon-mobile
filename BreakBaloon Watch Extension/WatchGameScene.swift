//
//  GameScene.swift
//  BreakBaloon Watch Extension
//
//  Created by Emil on 06/10/2019.
//  Copyright © 2019 Snowy_1803. All rights reserved.
//

import SpriteKit
import WatchKit

class WatchGameScene: SKScene {
    
    var cases:NSMutableArray
    let width = 3, height = 3
    var winCaseNumber:Int = -1
    var points:Int = 0
    
    var controller: InterfaceController!
    
    override init() {
        cases = NSMutableArray(capacity: self.width * self.height)
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize) {
        cases = NSMutableArray(capacity: self.width * self.height)
        super.init(size: size)
    }
    
    func construct() {
        backgroundColor = .white
        let baloonSize = min(self.size.width, self.size.height) / 4
        print("construct")
        for i in 0 ..< (width * height) {
            let theCase = Case(index: i)
            theCase.position = CGPoint(x: (CGFloat(i % width) + 0.5) * baloonSize + self.size.width / 8, y: (CGFloat(i / width) + 0.5) * baloonSize + self.size.height / 8)
            theCase.zPosition = 1
            theCase.size = CGSize(width: baloonSize, height: baloonSize)
            addChild(theCase)
            cases.add(theCase)
        }
        points = 0
        winCaseNumber = Int(arc4random_uniform(UInt32(width) * UInt32(height)))
    }
    
    override func sceneDidLoad() {
        construct()
    }
    
    func breakBaloon(_ index:Int, touch:CGPoint) {
        print("bb", index)
        if (cases.object(at: index) as! Case).breaked {
            return
        }
        (cases.object(at: index) as! Case).breakBaloon(index == winCaseNumber)
        var gameEnded = false
        if index == winCaseNumber {
            points += 1
            WKInterfaceDevice.current().play(.success)
            let plus = SKLabelNode(text: "+ 1")
            plus.fontColor = SKColor.blue
            plus.fontName = "HelveticaNeue-Bold"
            plus.fontSize = 10
            plus.setScale(0.01)
            plus.position = touch
            plus.zPosition = 3
            addChild(plus)
            print(plus, plus.frame)
            plus.run(SKAction.sequence([SKAction.wait(forDuration: TimeInterval(5)), SKAction.removeFromParent()]))
            var isThereUnbreakedBaloons = false
            for aCase in cases {
                if !(aCase as! Case).breaked {
                    isThereUnbreakedBaloons = true
                    break
                }
            }
            if !isThereUnbreakedBaloons {
                gameEnd()
                gameEnded = true
            }
            repeat {
                winCaseNumber = Int(arc4random_uniform(UInt32(width) * UInt32(height)))
            } while (cases.object(at: winCaseNumber) as! Case).breaked && !gameEnded
        }
        
        if !gameEnded {
            (cases.object(at: index) as! Case).baloonBreaked()
        }
    }
    
    func touchBegan(_ recognizer: WKLongPressGestureRecognizer) {
        let location = recognizer.locationInObject()
        let screenBounds = WKInterfaceDevice.current().screenBounds
        let newX = (location.x / screenBounds.width) * self.size.width
        let newY = -(location.y / screenBounds.height - 1) * self.size.height
        let point = CGPoint(x: newX, y: newY)
        if self.atPoint(point) is Case {
            breakBaloon((self.atPoint(point) as! Case).index, touch: point)
        }
    }
    
    func gameEnd() {
        let newRecord = UserDefaults.standard.integer(forKey: "highscore") < self.points
        let label = SKLabelNode(text: String(points) + " points")
        label.fontColor = SKColor.orange
        label.fontName = "HelveticaNeue-Bold"
        label.fontSize = 15
        label.setScale(0.01)
        label.zPosition = 1000
        label.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        print(label)
        self.addChild(label)
        label.run(SKAction.sequence([SKAction.wait(forDuration: TimeInterval(1)), SKAction.run({
            label.fontColor = SKColor.black
            if newRecord {
                label.text = "Highscore!" // NSLocalizedString("game.end.newrecord", comment: "")
            }
        }), SKAction.wait(forDuration: TimeInterval(newRecord ? 1.5 : 0.5)), SKAction.run({
            let data = UserDefaults.standard
            if data.integer(forKey: "highscore") < self.points {
                data.set(self.points, forKey: "highscore")
            }
            let oldXP = UserDefaults.standard.integer(forKey: "exp")
            let levelModifier = Float(max(10 - (oldXP / 250 + 1), 1))
            let sizeModifier = Float(self.width * self.height) / 100
            self.addXP(oldXP, Int(5 * levelModifier * sizeModifier))
            self.cases.removeAllObjects()
            self.removeAllChildren()
            self.construct()
        })]))
    }
    
    func addXP(_ oldXP: Int, _ xp: Int) {
        let levelBefore = (oldXP / 250 + 1)
        UserDefaults.standard.set(oldXP + xp, forKey: "exp")
        print("Added \(xp) XP")
        if levelBefore < ((oldXP + xp) / 250 + 1) {
            // Level up
        }
        print("XP:", oldXP + xp)
        controller.wcSession.transferUserInfo(["exp": oldXP + xp])
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
