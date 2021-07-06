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
    static let requirement = 6
    
    let gvc: GameViewController
    let nextBaloonMax: TimeInterval
    let label = SKLabelNode()
    let errors = SKLabelNode()
    var pause = SKSpriteNode()
    let level: RandGameLevel
    
    var baloonsToSpawn: UInt
    var nextBaloon: TimeInterval?
    
    init(view: SKView, level: RandGameLevel) {
        gvc = view.gvc
        self.level = level
        nextBaloonMax = level.maxSecondsBeforeNextBaloon
        baloonsToSpawn = level.numberOfBaloons
        super.init(view: view, gametype: .random)
        label.fontColor = SKColor.black
        if UIDevice.current.userInterfaceIdiom == .phone {
            label.fontSize = 12
        } else {
            label.fontSize = 30
        }
        label.fontName = "Verdana-Bold"
        label.position = CGPoint(x: label.frame.width / 2, y: 5 + view.safeAreaInsets.bottom)
        label.zPosition = 1
        updateLabel()
        addChild(label)
        if level.maxMissingBaloonToWin > 0 {
            errors.fontColor = SKColor.red
            if UIDevice.current.userInterfaceIdiom == .phone {
                errors.fontSize = 12
            } else {
                errors.fontSize = 30
            }
            errors.text = "0"
            errors.fontName = "Verdana-Bold"
            errors.position = CGPoint(x: frame.width - 30, y: 5 + view.safeAreaInsets.bottom)
            errors.zPosition = 1
            addChild(errors)
        }
        
        pause = SKSpriteNode(imageNamed: "pause")
        pause.position = CGPoint(
            x: frame.width - view.safeAreaInsets.right - pause.frame.width / 4 * 3,
            y: frame.height - view.safeAreaInsets.top - pause.frame.height / 4 * 3
        )
        pause.zPosition = 2
        beginTime = Date().timeIntervalSince1970
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(_: TimeInterval) {
        if !isGamePaused() {
            if nextBaloon == nil || (baloonsToSpawn > 0 && Date().timeIntervalSince1970 >= nextBaloon!) && canSpawnBaloon() {
                spawnBaloon()
            } else if baloonsToSpawn == 0, isEmpty(), endTime == nil {
                gameEnd()
            }
            errors.text = "\(getMissingBaloons())"
            if endTime == nil, getMissingBaloons() > Int(level.maxMissingBaloonToWin) {
                gameEnd()
            }
        }
    }
    
    func isEmpty() -> Bool {
        !children.contains(where: { $0 is Case })
    }
    
    func canSpawnBaloon() -> Bool {
        numberOfBaloonsInGame() < level.maxBaloonsAtSameTime
    }
    
    func numberOfBaloonsInGame() -> UInt {
        var i: UInt = 0
        for aCase in children where aCase is Case {
            i += 1
        }
        return i
    }
    
    func numberOfClosedBaloonsInGame() -> UInt {
        var i: UInt = 0
        for aCase in children {
            if let aCase = aCase as? Case, aCase.status == .closed, !(aCase is FakeCase) {
                i += 1
            }
        }
        return i
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
        if !isGamePaused() {
            for touch in touches {
                let point = touch.location(in: self)
                for aCase in children {
                    if let aCase = aCase as? Case, aCase.frame.extends(10).contains(point) {
                        breakBaloon(case: aCase, touch: point)
                        return
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with _: UIEvent?) {
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
                    } else if let child = child as? RandGameLevelEndNode {
                        child.click(touches.first!.location(in: self))
                    } else if let child = child as? RandGamePauseNode {
                        child.touchAt(touches.first!.location(in: self))
                    }
                }
            }
        }
    }
    
    func breakBaloon(case aCase: Case, touch _: CGPoint) {
        if aCase.status == .closed {
            aCase.breakBaloon(false)
            points += 1
            updateLabel()
            aCase.baloonBreaked()
            playPump(winner: false)
        }
    }
    
    func spawnBaloon(case aCase: Case) {
        addChild(aCase)
        nextBaloon = Date().timeIntervalSince1970 + Double.random(in: 0...nextBaloonMax)
        if !(aCase is FakeCase) {
            baloonsToSpawn -= 1
        }
    }
    
    func spawnBaloon(point: CGPoint) {
        let aCase: Case
        if level.fakeBaloonsRate > Float.random(in: 0..<1) {
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
        let area = frame.inset(by: view!.safeAreaInsets).inset(by: UIEdgeInsets(top: 105, left: 0, bottom: 75, right: 75))
        spawnBaloon(point: CGPoint(x: CGFloat.random(in: area.minX ..< area.maxX), y: CGFloat.random(in: area.minY ..< area.maxY)))
    }
    
    func getMissingBaloons() -> Int {
        ((Int(level.numberOfBaloons) - Int(baloonsToSpawn)) - points) - Int(numberOfClosedBaloonsInGame())
    }
    
    func gameEnd() {
        pause.removeFromParent()
        endTime = Date().timeIntervalSince1970 - beginTime!
        level.end(getMissingBaloons())
        updateLabel()

        label.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.run {
            self.label.fontColor = SKColor.orange
        }, SKAction.wait(forDuration: 1), SKAction.run {
            self.label.fontColor = SKColor.black
        }, SKAction.wait(forDuration: 0.5), SKAction.run {
            if UserDefaults.standard.integer(forKey: "bestTimedScore") < self.points {
                UserDefaults.standard.set(self.points, forKey: "bestRandomScore")
            }
            let gvc = self.view!.gvc!
            gvc.currentGame = nil
            gvc.addXP(5)
        }]))
    }
    
    func updateLabel() {
        label.text = String(format: NSLocalizedString("game.score.\(points > 1 ? "more" : "one")", comment: "Points at end"), points)
        label.position.x = label.frame.width / 2
    }
    
    override func isGamePaused() -> Bool {
        for aCase in children where aCase is RandGameLevelInfoNode {
            return true
        }
        return endTime != nil || super.isGamePaused()
    }
}

extension CGRect {
    func extends(_ cubicRadius: CGFloat) -> CGRect {
        CGRect(x: minX - cubicRadius, y: minY - cubicRadius, width: width + cubicRadius * 2, height: height + cubicRadius * 2)
    }
}
