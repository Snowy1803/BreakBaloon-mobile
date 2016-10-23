//
//  GameScene.swift
//  BreakBaloon
//
//  Created by Emil on 20/06/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import AVFoundation
import SpriteKit

class GameScene:AbstractGameScene {
    
    var width:Int
    var height:Int
    var cases:NSMutableArray
    var label:SKLabelNode = SKLabelNode()
    var winCaseNumber:Int = -1
    var computerpoints:Int = 0
    var waitingForComputer:Bool = false
    
    init(view:SKView, gametype:Int8, width:UInt, height:UInt) {
        self.width = Int(width)
        self.height = Int(height)
        cases = NSMutableArray(capacity: self.width * self.height)
        super.init(view: view, gametype: gametype)
    }
    
    override func construct(_ gvc: GameViewController) {
        super.construct(gvc)
        for i in 0 ..< (width * height) {
            let theCase = Case(gvc: gvc, index: i)
            theCase.position = CGPoint(x: CGFloat(i % width * 75 + 35), y: self.frame.size.height - CGFloat(i / width * 75 + 35))
            theCase.zPosition = 1
            addChild(theCase)
            cases.add(theCase)
        }
        if gametype == StartScene.GAMETYPE_SOLO {
            label.text = NSLocalizedString("game.score.no", comment: "No points")
        } else if gametype == StartScene.GAMETYPE_COMPUTER {
            label.text = NSLocalizedString("game.score.vsc.no.no", comment: "No points both")
        } else if gametype == StartScene.GAMETYPE_TIMED {
            label.text = String(format: NSLocalizedString("game.time", comment: "Time"), 0)
        }
        label.fontColor = SKColor.black
        if UIDevice.current.userInterfaceIdiom == .phone {
            label.fontSize = 12
        } else {
            label.fontSize = 30
        }
        label.fontName = "Verdana-Bold"
        label.position = CGPoint(x: label.frame.width/2, y: 5)
        label.zPosition = 2
        addChild(label)
        winCaseNumber = Int(arc4random_uniform(UInt32(width) * UInt32(height)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func breakBaloon(_ index:Int, touch:CGPoint, computer:Bool) {
        if waitingForComputer && !computer {
            return
        }
        if beginTime == nil {
            beginTime = Date().timeIntervalSince1970
        }
        if (cases.object(at: index) as! Case).breaked {
            return
        }
        (cases.object(at: index) as! Case).breakBaloon(index == winCaseNumber)
        var data:Data
        var gameEnded = false
        if gametype != StartScene.GAMETYPE_TIMED && index == winCaseNumber {
            if computer {
                computerpoints += 1
            } else {
                points += 1
            }
            if gametype == StartScene.GAMETYPE_SOLO {
                label.text = String(format: NSLocalizedString("game.score.\(points > 1 ? "more" : "one")", comment: "Number of points"), points)
            } else if gametype == StartScene.GAMETYPE_COMPUTER {
                label.text = String(format: NSLocalizedString("game.score.vsc.\(points > 1 ? "more" : "one").\(computerpoints > 1 ? "more" : "one")", comment: "Number of points both"), points, computerpoints)
            }
            label.position = CGPoint(x: label.frame.width/2, y: 5)
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
            data = (self.view?.window?.rootViewController as! GameViewController).currentTheme.pumpSound(true)
        } else if gametype == StartScene.GAMETYPE_TIMED {
            var isThereUnbreakedBaloons = false
            for aCase in cases {
                if !(aCase as! Case).breaked {
                    isThereUnbreakedBaloons = true
                    break
                }
            }
            if !isThereUnbreakedBaloons {
                gameEnd()
            }
            data = (self.view?.window?.rootViewController as! GameViewController).currentTheme.pumpSound(false)
        } else {
            data = (self.view?.window?.rootViewController as! GameViewController).currentTheme.pumpSound(false)
        }
        
        if !gameEnded {
            (cases.object(at: index) as! Case).baloonBreaked()
        }
        
        do {
            avplayer = try AVAudioPlayer(data: data)
            avplayer.volume = (self.view?.window?.rootViewController as! GameViewController).audioVolume
            avplayer.prepareToPlay()
            avplayer.play()
        } catch {
            print("Error playing sound at \(data)")
        }
        
        if !gameEnded && !computer && gametype == StartScene.GAMETYPE_COMPUTER {
            waitingForComputer = true
            self.run(SKAction.sequence([SKAction.wait(forDuration: TimeInterval(0.25)), SKAction.run({
                var wherebreak:Int
                repeat {
                    wherebreak = Int(arc4random_uniform(UInt32(self.width) * UInt32(self.height)))
                } while (self.cases.object(at: wherebreak) as! Case).breaked
                self.breakBaloon(wherebreak, touch: (self.cases.object(at: wherebreak) as AnyObject).position, computer: true)
                self.waitingForComputer = false
            })]))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let point = touch.location(in: self)
            if self.atPoint(point) is Case {
                breakBaloon((self.atPoint(point) as! Case).index, touch: point, computer: false)
            }
        }
    }
    
    func gameEnd() {
        endTime = Date().timeIntervalSince1970 - beginTime!
        if self.gametype == StartScene.GAMETYPE_COMPUTER {
            if self.points > self.computerpoints {
                label.text = String(format: NSLocalizedString("game.score.vsc.end.won", comment: "Points at end"), self.points, self.computerpoints)
            } else if self.computerpoints > self.points {
                label.text = String(format: NSLocalizedString("game.score.vsc.end.lost", comment: "Points at end"), self.computerpoints, self.points)
            } else {
                label.text = String(format: NSLocalizedString("game.score.vsc.end.same", comment: "Points at end"), self.points)
            }
            label.position = CGPoint(x: label.frame.width/2, y: 5)
        } else if self.gametype == StartScene.GAMETYPE_TIMED {
            points = Int((Float(width * height) / Float(endTime!)) * 5)
            label.text = String(format: NSLocalizedString("game.score.time", comment: "Points at end"), self.points, Int(self.endTime!))
            label.position = CGPoint(x: label.frame.width/2, y: 5)
        }
        let newRecord = self.gametype == StartScene.GAMETYPE_SOLO && UserDefaults.standard.integer(forKey: "highscore") < self.points || self.gametype == StartScene.GAMETYPE_TIMED && UserDefaults.standard.integer(forKey: "bestTimedScore") < self.points
        label.run(SKAction.sequence([SKAction.wait(forDuration: TimeInterval(0.5)), SKAction.run({
            self.label.fontColor = SKColor.orange
        }), SKAction.wait(forDuration: TimeInterval(1)), SKAction.run({
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
        }), SKAction.wait(forDuration: TimeInterval(newRecord ? 1.5 : 0.5)), SKAction.run({
            let data = UserDefaults.standard
            if self.gametype == StartScene.GAMETYPE_SOLO && data.integer(forKey: "highscore") < self.points {
                data.set(self.points, forKey: "highscore")
            } else if self.gametype == StartScene.GAMETYPE_TIMED && data.integer(forKey: "bestTimedScore") < self.points {
                data.set(self.points, forKey: "bestTimedScore")
            }
            let gvc = self.view!.window!.rootViewController as! GameViewController
            gvc.currentGame = nil
            let levelModifier = Float(max(10 - GameViewController.getLevel(), 1))
            let sizeModifier = Float(self.width * self.height) / 100
            gvc.addXP(Int(5 * levelModifier * sizeModifier))
            let scene:StartScene = StartScene(size: self.frame.size)
            scene.lastGameInfo = self.label.text!
            self.view!.presentScene(scene, transition: SKTransition.flipVertical(withDuration: TimeInterval(1)))
        })]))
    }
    
    override func update(_ currentTime: TimeInterval) {
        if gametype == StartScene.GAMETYPE_TIMED && endTime == nil && !isGamePaused() {
            label.text = String(format: NSLocalizedString("game.time", comment: "Time"), (beginTime == nil ? 0 : Int(Date().timeIntervalSince1970 - beginTime!)))
            label.position = CGPoint(x: label.frame.width/2, y: 5)
        }
    }
}
