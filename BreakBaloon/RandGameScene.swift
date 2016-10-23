//
//  RandGameScene.swift
//  BreakBaloon
//
//  Created by Emil on 29/07/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import AVFoundation
import SpriteKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class RandGameScene: AbstractGameScene {
    static let REQUIREMENT = 6
    
    let gvc:GameViewController
    let nextBaloonMax:TimeInterval
    let label = SKLabelNode()
    let errors = SKLabelNode()
    var pause = SKSpriteNode()
    let level: RandGameLevel
    
    var baloonsToSpawn:UInt
    var nextBaloon:TimeInterval?
    
    init(view: SKView, level: RandGameLevel) {
        gvc = view.window?.rootViewController as! GameViewController
        self.level = level
        self.nextBaloonMax = level.maxSecondsBeforeNextBaloon
        baloonsToSpawn = level.numberOfBaloons
        super.init(view: view, gametype: StartScene.GAMETYPE_RAND)
        label.fontColor = SKColor.black
        if UIDevice.current.userInterfaceIdiom == .phone {
            label.fontSize = 12
        } else {
            label.fontSize = 30
        }
        label.fontName = "Verdana-Bold"
        label.position = CGPoint(x: label.frame.width/2, y: 5)
        label.zPosition = 1
        updateLabel()
        addChild(label)
        if (level.maxMissingBaloonToWin > 0) {
            errors.fontColor = SKColor.red
            if UIDevice.current.userInterfaceIdiom == .phone {
                errors.fontSize = 12
            } else {
                errors.fontSize = 30
            }
            errors.text = "0"
            errors.fontName = "Verdana-Bold"
            errors.position = CGPoint(x: self.frame.width - 30, y: 5)
            errors.zPosition = 1
            addChild(errors)
        }
        pause = SKSpriteNode(imageNamed: "pause")
        pause.position = CGPoint(x: self.frame.width - pause.frame.width / 4 * 3, y: self.frame.height - pause.frame.height / 4 * 3)
        pause.zPosition = 2
        beginTime = Date().timeIntervalSince1970
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(_ currentTime: TimeInterval) {
        if !isGamePaused() {
            if nextBaloon == nil || (baloonsToSpawn > 0 && Date().timeIntervalSince1970 >= nextBaloon) && canSpawnBaloon() {
                spawnBaloon()
            } else if baloonsToSpawn == 0 && isEmpty() && endTime == nil {
                gameEnd()
            }
            errors.text = "\(getMissingBaloons())"
            if endTime == nil && getMissingBaloons() > Int(level.maxMissingBaloonToWin) {
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
        return numberOfBaloonsInGame() < level.maxBaloonsAtSameTime
    }
    
    func numberOfBaloonsInGame() -> UInt {
        var i:UInt = 0
        for aCase in children {
            if aCase is Case {
                i += 1
            }
        }
        return i
    }
    
    func numberOfClosedBaloonsInGame() -> UInt {
        var i:UInt = 0
        for aCase in children {
            if aCase is Case && (aCase as! Case).status == .closed  && !(aCase is FakeCase) {
                i += 1
            }
        }
        return i
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isGamePaused() {
            for touch in touches {
                let point = touch.location(in: self)
                for aCase in children {
                    if aCase is Case && aCase.frame.extends(10).contains(point) {
                        breakBaloon(case: aCase as! Case, touch: point)
                        return
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 1 {
            let point = touches.first!.location(in: self)
            if pause.frame.contains(point) {
                pauseGame()
                pause.removeFromParent()
                addChild(RandGamePauseNode(scene: self))
            } else {
                for child in children {
                    if child is RandGameLevelInfoNode {
                        beginTime = Date().timeIntervalSince1970
                        quitPause()
                        child.removeFromParent()
                        addChild(pause)
                        break
                    } else if child is RandGameLevelEndNode {
                        (child as! RandGameLevelEndNode).click(touches.first!.location(in: self))
                    } else if child is RandGamePauseNode {
                        (child as! RandGamePauseNode).touchAt(touches.first!.location(in: self))
                    }
                }
            }
        }
    }
    
    func breakBaloon(case aCase: Case, touch: CGPoint) {
        if aCase.status == .closed {
            aCase.breakBaloon(false)
            points += 1
            updateLabel()
            aCase.baloonBreaked()
            do {
                avplayer = try AVAudioPlayer(data: (self.view?.window?.rootViewController as! GameViewController).currentTheme.pumpSound(false))
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
        nextBaloon = Date().timeIntervalSince1970 + TimeInterval(Double(arc4random_uniform(UInt32(nextBaloonMax * 1000))) / 1000)
        if !(aCase is FakeCase) {
            baloonsToSpawn -= 1
        }
    }
    
    func spawnBaloon(point: CGPoint) {
        let aCase: Case
        if level.fakeBaloonsRate > Float.random() {
            aCase = FakeCase(gvc: gvc, index: -1)
        } else {
            aCase = Case(gvc: gvc, index: -1)
        }
        aCase.position = point
        aCase.zPosition = 0
        aCase.run(SKAction.sequence([SKAction.wait(forDuration: level.secondsBeforeBaloonVanish), SKAction.fadeOut(withDuration: 0.5), SKAction.removeFromParent()]))
        spawnBaloon(case: aCase)
    }
    
    /// Spawn a baloon at a random location
    func spawnBaloon() {
        spawnBaloon(point: CGPoint(x: CGFloat(arc4random_uniform(UInt32(self.frame.width - 75))), y: CGFloat(arc4random_uniform(UInt32(self.frame.height - 105)) + 75)))
    }
    
    func getMissingBaloons() -> Int {
        return ((Int(level.numberOfBaloons) - Int(baloonsToSpawn)) - points) - Int(numberOfClosedBaloonsInGame())
    }
    
    func gameEnd() {
        pause.removeFromParent()
        endTime = Date().timeIntervalSince1970 - beginTime!
        level.end(getMissingBaloons())
        updateLabel()

        label.run(SKAction.sequence([SKAction.wait(forDuration: TimeInterval(0.5)), SKAction.run({
            self.label.fontColor = SKColor.orange
        }), SKAction.wait(forDuration: TimeInterval(1)), SKAction.run({
            self.label.fontColor = SKColor.black
        }), SKAction.wait(forDuration: TimeInterval(0.5)), SKAction.run({
            if UserDefaults.standard.integer(forKey: "bestTimedScore") < self.points {
                UserDefaults.standard.set(self.points, forKey: "bestRandomScore")
            }
            let gvc = self.view!.window!.rootViewController as! GameViewController
            gvc.currentGame = nil
            gvc.addXP(Int(5))
        })]))
    }
    
    func updateLabel() {
        label.text = String(format: NSLocalizedString("game.score.\(points > 1 ? "more" : "one")", comment: "Points at end"), self.points)
        label.position = CGPoint(x: label.frame.width/2, y: 5)
    }
    
    override func isGamePaused() -> Bool {
        for aCase in children {
            if aCase is RandGameLevelInfoNode {
                return true
            }
        }
        return endTime != nil || super.isGamePaused()
    }
}

extension CGRect {
    func extends(_ cubicRadius: CGFloat) -> CGRect {
        return CGRect(x: self.minX - cubicRadius, y: self.minY - cubicRadius, width: self.width + cubicRadius * 2, height: self.height + cubicRadius * 2)
    }
}
