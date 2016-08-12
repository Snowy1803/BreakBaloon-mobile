//
//  RandGameScene.swift
//  BreakBaloon
//
//  Created by Emil on 29/07/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import AVFoundation
import SpriteKit

class RandGameScene: AbstractGameScene {
    static let REQUIREMENT = 6
    
    let gvc:GameViewController
    let numberOfBaloons:UInt
    let baloonTime:NSTimeInterval
    let nextBaloonMax:NSTimeInterval
    let maxBaloons: UInt
    let fakeBaloonRate: Float
    let completion:((Int) -> Void)?
    let label = SKLabelNode()
    var pause = SKSpriteNode()
    let level: RandGameLevel
    
    var baloonsToSpawn:UInt
    var nextBaloon:NSTimeInterval?
    
    init(view: SKView, level: RandGameLevel) {
        gvc = view.window?.rootViewController as! GameViewController
        self.level = level
        self.numberOfBaloons = level.numberOfBaloons
        self.baloonTime = level.secondsBeforeBaloonVanish
        self.nextBaloonMax = level.maxSecondsBeforeNextBaloon
        self.completion = level.end
        baloonsToSpawn = numberOfBaloons
        self.maxBaloons = level.maxBaloonsAtSameTime
        self.fakeBaloonRate = level.fakeBaloonsRate
        super.init(view: view, gametype: StartScene.GAMETYPE_RAND)
        label.fontColor = SKColor.blackColor()
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            label.fontSize = 12
        } else {
            label.fontSize = 30
        }
        label.fontName = "Verdana-Bold"
        label.position = CGPointMake(label.frame.width/2, 5)
        label.zPosition = 1
        updateLabel()
        addChild(label)
        pause = SKSpriteNode(imageNamed: "pause")
        pause.position = CGPointMake(self.frame.width - pause.frame.width / 4 * 3, self.frame.height - pause.frame.height / 4 * 3)
        pause.zPosition = 2
        beginTime = NSDate().timeIntervalSince1970
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(currentTime: NSTimeInterval) {
        if !isGamePaused() {
            if nextBaloon == nil || (baloonsToSpawn > 0 && NSDate().timeIntervalSince1970 >= nextBaloon) && canSpawnBaloon() {
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
    
    func canSpawnBaloon() -> Bool {
        var i:UInt = 0
        for aCase in children {
            if aCase is Case {
                i += 1
            }
        }
        return i < maxBaloons
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !isGamePaused() {
            for touch in touches {
                let point = touch.locationInNode(self)
                for aCase in children {
                    if aCase is Case && aCase.frame.extends(10).contains(point) {
                        breakBaloon(case: aCase as! Case, touch: point)
                        return
                    }
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touches.count == 1 {
            let point = touches.first!.locationInNode(self)
            if pause.frame.contains(point) {
                pauseGame()
                pause.removeFromParent()
                addChild(RandGamePauseNode(scene: self))
            } else {
                for child in children {
                    if child is RandGameLevelInfoNode {
                        beginTime = NSDate().timeIntervalSince1970
                        quitPause()
                        child.removeFromParent()
                        addChild(pause)
                        break
                    } else if child is RandGameLevelEndNode {
                        (child as! RandGameLevelEndNode).click(touches.first!.locationInNode(self))
                    } else if child is RandGamePauseNode {
                        (child as! RandGamePauseNode).touchAt(touches.first!.locationInNode(self))
                    }
                }
            }
        }
    }
    
    func breakBaloon(case aCase: Case, touch: CGPoint) {
        if aCase.status == .Closed {
            aCase.breakBaloon(false)
            points += 1
            updateLabel()
            aCase.baloonBreaked()
            do {
                avplayer = try AVAudioPlayer(contentsOfURL: (self.view?.window?.rootViewController as! GameViewController).currentTheme.pumpSound(false))
                avplayer.volume = (self.view?.window?.rootViewController as! GameViewController).audioVolume
                avplayer.prepareToPlay()
                avplayer.play()
            } catch {
                print("Error playing pump sound")
            }
        }
    }
    
    func spawnBaloon(case aCase: Case) {
        addChild(aCase)
        nextBaloon = NSDate().timeIntervalSince1970 + NSTimeInterval(Double(arc4random_uniform(UInt32(nextBaloonMax * 1000))) / 1000)
        if !(aCase is FakeCase) {
            baloonsToSpawn -= 1
        }
    }
    
    func spawnBaloon(point point: CGPoint) {
        let aCase: Case
        if fakeBaloonRate > Float.random() {
            aCase = FakeCase(gvc: gvc, index: -1)
        } else {
            aCase = Case(gvc: gvc, index: -1)
        }
        aCase.position = point
        aCase.zPosition = 0
        aCase.runAction(SKAction.sequence([SKAction.waitForDuration(baloonTime), SKAction.fadeOutWithDuration(0.5), SKAction.removeFromParent()]))
        spawnBaloon(case: aCase)
    }
    
    /// Spawn a baloon at a random location
    func spawnBaloon() {
        spawnBaloon(point: CGPointMake(CGFloat(arc4random_uniform(UInt32(self.frame.width - 75))), CGFloat(arc4random_uniform(UInt32(self.frame.height - 105)) + 75)))
    }
    
    func gameEnd() {
        endTime = NSDate().timeIntervalSince1970 - beginTime!
        completion!(Int(numberOfBaloons) - points)
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
        })]))
    }
    
    func updateLabel() {
        label.text = String(format: NSLocalizedString("game.score.\(points > 1 ? "more" : "one")", comment: "Points at end"), self.points)
        label.position = CGPointMake(label.frame.width/2, 5)
    }
    
    override func isGamePaused() -> Bool {
        for aCase in children {
            if aCase is RandGameLevelInfoNode {
                return true
            }
        }
        return super.isGamePaused()
    }
}

extension CGRect {
    func extends(cubicRadius: CGFloat) -> CGRect {
        return CGRectMake(self.minX - cubicRadius, self.minY - cubicRadius, self.width + cubicRadius * 2, self.height + cubicRadius * 2)
    }
}