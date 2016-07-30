//
//  RandGameScene.swift
//  BreakBaloon
//
//  Created by Emil on 29/07/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit

class RandGameScene: AbstractGameScene {
    static let REQUIREMENT = 6
    
    let gvc:GameViewController
    let numberOfBaloons:UInt
    let baloonTime:NSTimeInterval
    let nextBaloonMax:NSTimeInterval
    let completion:((UInt) -> Void)?
    var label:SKLabelNode = SKLabelNode()
    
    var baloonsToSpawn:UInt
    var nextBaloon:NSTimeInterval?
    
    init(view: SKView, numberOfBaloons: UInt, baloonTime: NSTimeInterval, speed: NSTimeInterval, completion:((UInt) -> Void)?) {
        gvc = view.window?.rootViewController as! GameViewController
        self.numberOfBaloons = numberOfBaloons
        self.baloonTime = baloonTime
        self.nextBaloonMax = speed
        self.completion = completion
        baloonsToSpawn = numberOfBaloons
        super.init(view: view, gametype: StartScene.GAMETYPE_RAND)
        label = SKLabelNode()
        label.fontColor = SKColor.blackColor()
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            label.fontSize = 12
        } else {
            label.fontSize = 30
        }
        label.fontName = "Verdana-Bold"
        label.position = CGPointMake(label.frame.width/2, 5)
        label.zPosition = CGFloat(numberOfBaloons) + 1
        updateLabel()
        addChild(label)
        beginTime = NSDate().timeIntervalSince1970
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(currentTime: NSTimeInterval) {
        if pauseTime == nil {
            if nextBaloon == nil || (baloonsToSpawn > 0 && NSDate().timeIntervalSince1970 >= nextBaloon) {
                spawnBaloon()
            } else if baloonsToSpawn == 0 && isEmpty() && endTime == nil {
                gameEnd()
            }
        }
    }
    
    func isEmpty() -> Bool {
        for aCase in children {
            if aCase is Case {
                return false
            }
        }
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touches.count == 1 {
            let touch = touches.first!.locationInNode(self)
            for aCase in children {
                if aCase is Case && aCase.frame.contains(touch) {
                    breakBaloon(case: aCase as! Case, touch: touch)
                    return
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touches.count == 1 {
            for child in children {
                if child is RandGameLevelInfoNode {
                    quitPause()
                    child.removeFromParent()
                    break
                }
            }
        }
    }
    
    func breakBaloon(case aCase: Case, touch: CGPoint) {
        print("HEY?")
        if aCase.status == .Closed {
            print("HEY!")
            aCase.breakBaloon(false)
            points += 1
            updateLabel()
        }
    }
    
    func spawnBaloon(case aCase: Case) {
        addChild(aCase)
        nextBaloon = NSDate().timeIntervalSince1970 + NSTimeInterval(arc4random_uniform(UInt32(nextBaloonMax * 1000)) / 1000)
        print(nextBaloonMax)
        print(NSTimeInterval(arc4random_uniform(UInt32(nextBaloonMax * 1000)) / 1000))
        baloonsToSpawn -= 1
        
    }
    
    func spawnBaloon(point point: CGPoint) {
        let aCase = Case(gvc: gvc, index: -1)
        aCase.position = point
        aCase.zPosition = CGFloat(numberOfBaloons - baloonsToSpawn)
        aCase.runAction(SKAction.sequence([SKAction.waitForDuration(baloonTime), SKAction.fadeOutWithDuration(0.5), SKAction.removeFromParent()]))
        spawnBaloon(case: aCase)
    }
    
    /// Spawn a baloon at a random location
    func spawnBaloon() {
        spawnBaloon(point: CGPointMake(CGFloat(arc4random_uniform(UInt32(self.frame.width - 75))), CGFloat(arc4random_uniform(UInt32(self.frame.height - 75)))))
    }
    
    func gameEnd() {
        completion!(numberOfBaloons - UInt(points))
        endTime = NSDate().timeIntervalSince1970 - beginTime!
        updateLabel()

        label.runAction(SKAction.sequence([SKAction.waitForDuration(NSTimeInterval(0.5)), SKAction.runBlock({
            self.label.fontColor = SKColor.orangeColor()
        }), SKAction.waitForDuration(NSTimeInterval(1)), SKAction.runBlock({
            self.label.fontColor = SKColor.blackColor()
        }), SKAction.waitForDuration(NSTimeInterval(0.5)), SKAction.runBlock({
            if NSUserDefaults.standardUserDefaults().integerForKey("bestTimedScore") < self.points {
                NSUserDefaults.standardUserDefaults().setInteger(self.points, forKey: "bestRandomScore")
            }
            let gvc = self.view!.window!.rootViewController as! GameViewController
            gvc.currentGame = nil
            gvc.addXP(Int(5))
            let scene:StartScene = StartScene(size: self.frame.size)
            scene.lastGameInfo = NSLocalizedString(self.label.text!, comment: "Last game info")
            self.view!.presentScene(scene, transition: SKTransition.flipVerticalWithDuration(NSTimeInterval(1)))
        })]))
    }
    
    func updateLabel() {
        label.text = String(format: NSLocalizedString("game.score.\(points > 1 ? "more" : "one")", comment: "Points at end"), self.points)
        label.position = CGPointMake(label.frame.width/2, 5)
    }
}