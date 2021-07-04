//
//  GameScene.swift
//  BreakBaloon
//
//  Created by Emil on 20/06/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import AVFoundation
import SpriteKit

class GameScene: AbstractGameScene {
    var width: Int
    var height: Int
    var cases: [Case]
    var label = SKLabelNode()
    var winCaseNumber: Int = -1
    var computerpoints: Int = 0
    var waitingForComputer: Bool = false
    
    init(view: SKView, gametype: GameType, width: Int, height: Int) {
        self.width = width
        self.height = height
        cases = []
        cases.reserveCapacity(self.width * self.height)
        super.init(view: view, gametype: gametype)
    }
    
    override func construct(_ gvc: GameViewController) {
        super.construct(gvc)
        let top = frame.size.height - (gvc.view?.safeAreaInsets.top ?? 0)
        let left = gvc.view?.safeAreaInsets.left ?? 0
        for i in 0 ..< (width * height) {
            let theCase = Case(gvc: gvc, index: i)
            theCase.position = CGPoint(x: left + CGFloat(i % width * 75 + 35), y: top - CGFloat(i / width * 75 + 35))
            theCase.zPosition = 1
            addChild(theCase)
            cases.append(theCase)
        }
        switch gametype {
        case .solo:
            label.text = NSLocalizedString("game.score.no", comment: "No points")
        case .computer:
            label.text = NSLocalizedString("game.score.vsc.no.no", comment: "No points both")
        case .timed:
            label.text = String(format: NSLocalizedString("game.time", comment: "Time"), 0)
        case .undefined, .random:
            assertionFailure()
        }
        label.fontColor = SKColor.black
        if UIDevice.current.userInterfaceIdiom == .phone {
            label.fontSize = 12
        } else {
            label.fontSize = 30
        }
        label.fontName = "Verdana-Bold"
        label.position = CGPoint(x: label.frame.width / 2, y: 5 + (gvc.view?.safeAreaInsets.bottom ?? 0))
        label.zPosition = 2
        addChild(label)
        winCaseNumber = Int(arc4random_uniform(UInt32(width) * UInt32(height)))
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func breakBaloon(_ index: Int, touch: CGPoint, computer: Bool) {
        if waitingForComputer, !computer {
            return
        }
        if beginTime == nil {
            beginTime = Date().timeIntervalSince1970
        }
        let touched = cases[index]
        guard !touched.breaked else {
            return
        }
        touched.breakBaloon(index == winCaseNumber)
        var winningSound: Bool
        var gameEnded = false
        if gametype != .timed, index == winCaseNumber {
            if computer {
                computerpoints += 1
            } else {
                points += 1
            }
            if gametype == .solo {
                label.text = String(format: NSLocalizedString("game.score.\(points > 1 ? "more" : "one")", comment: "Number of points"), points)
            } else if gametype == .computer {
                label.text = String(format: NSLocalizedString("game.score.vsc.\(points > 1 ? "more" : "one").\(computerpoints > 1 ? "more" : "one")", comment: "Number of points both"), points, computerpoints)
            }
            label.position.x = label.frame.width / 2
            let plus = SKLabelNode(text: "+ 1")
            if computer {
                plus.fontColor = SKColor.red
            } else {
                plus.fontColor = SKColor.blue
            }
            plus.fontName = "Verdana-Bold"
            plus.fontSize = 25
            plus.position = touch
            plus.zPosition = 3
            addChild(plus)
            plus.run(SKAction.sequence([SKAction.wait(forDuration: 5), SKAction.removeFromParent()]))
            var isThereUnbreakedBaloons = false
            for aCase in cases where !aCase.breaked {
                isThereUnbreakedBaloons = true
                break
            }
            if !isThereUnbreakedBaloons {
                gameEnd()
                gameEnded = true
            }
            repeat {
                winCaseNumber = Int(arc4random_uniform(UInt32(width) * UInt32(height)))
            } while cases[winCaseNumber].breaked && !gameEnded
            winningSound = true
        } else if gametype == .timed {
            var isThereUnbreakedBaloons = false
            for aCase in cases where !aCase.breaked {
                isThereUnbreakedBaloons = true
                break
            }
            if !isThereUnbreakedBaloons {
                gameEnd()
            }
            winningSound = false
        } else {
            winningSound = false
        }
        
        if !gameEnded {
            touched.baloonBreaked()
        }
        
        playPump(winner: winningSound)
        
        if !gameEnded, !computer, gametype == .computer {
            waitingForComputer = true
            run(SKAction.sequence([SKAction.wait(forDuration: 0.25), SKAction.run {
                var wherebreak: Int
                repeat {
                    wherebreak = Int(arc4random_uniform(UInt32(self.width) * UInt32(self.height)))
                } while self.cases[wherebreak].breaked
                self.breakBaloon(wherebreak, touch: self.cases[wherebreak].position, computer: true)
                self.waitingForComputer = false
            }]))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
        for touch in touches {
            let point = touch.location(in: self)
            if let touched = atPoint(point) as? Case {
                breakBaloon(touched.index, touch: point, computer: false)
            }
        }
    }
    
    func gameEnd() {
        endTime = Date().timeIntervalSince1970 - beginTime!
        if gametype == .computer {
            if points > computerpoints {
                label.text = String(format: NSLocalizedString("game.score.vsc.end.won", comment: "Points at end"), points, computerpoints)
            } else if computerpoints > points {
                label.text = String(format: NSLocalizedString("game.score.vsc.end.lost", comment: "Points at end"), computerpoints, points)
            } else {
                label.text = String(format: NSLocalizedString("game.score.vsc.end.same", comment: "Points at end"), points)
            }
            label.position.x = label.frame.width / 2
        } else if gametype == .timed {
            points = Int((Float(width * height) / Float(endTime!)) * 5)
            label.text = String(format: NSLocalizedString("game.score.time", comment: "Points at end"), points, Int(endTime!))
            label.position.x = label.frame.width / 2
        }
        let newRecord = (gametype == .solo && UserDefaults.standard.integer(forKey: "highscore") < points) || (gametype == .timed && UserDefaults.standard.integer(forKey: "bestTimedScore") < points)
        label.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.run {
            self.label.fontColor = SKColor.orange
        }, SKAction.wait(forDuration: 1), SKAction.run {
            self.label.fontColor = SKColor.black
            if newRecord {
                let record = SKLabelNode(text: NSLocalizedString("game.end.newrecord", comment: ""))
                record.fontColor = SKColor.orange
                record.fontName = "Verdana-Bold"
                record.fontSize = 25
                record.zPosition = 1000
                record.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                self.addChild(record)
            }
        }, SKAction.wait(forDuration: newRecord ? 1.5 : 0.5), SKAction.run {
            let data = UserDefaults.standard
            if self.gametype == .solo, data.integer(forKey: "highscore") < self.points {
                data.set(self.points, forKey: "highscore")
            } else if self.gametype == .timed, data.integer(forKey: "bestTimedScore") < self.points {
                data.set(self.points, forKey: "bestTimedScore")
            }
            let gvc = self.view!.gvc!
            gvc.currentGame = nil
            let oldXP = CGFloat(GameViewController.getLevelXPFloat())
            let levelModifier = Float(max(10 - GameViewController.getLevel(), 1))
            let sizeModifier = Float(self.width * self.height) / 100
            gvc.addXP(Int(5 * levelModifier * sizeModifier))
            let scene = StartScene(size: self.frame.size, growXPFrom: oldXP)
            scene.lastGameInfo = self.label.text!
            self.view!.presentScene(scene, transition: SKTransition.flipVertical(withDuration: 1))
        }]))
    }
    
    override func update(_: TimeInterval) {
        if gametype == .timed, endTime == nil, !isGamePaused() {
            label.text = String(format: NSLocalizedString("game.time", comment: "Time"), beginTime == nil ? 0 : Int(Date().timeIntervalSince1970 - beginTime!))
            label.position.x = label.frame.width / 2
        }
    }
}
