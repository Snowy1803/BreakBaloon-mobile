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
    
    override func construct(gvc: GameViewController) {
        super.construct(gvc)
        for i in 0 ..< (width * height) {
            let theCase = Case(gvc: gvc, index: i)
            theCase.position = CGPointMake(CGFloat(i % width * 75 + 35), self.frame.size.height - CGFloat(i / width * 75 + 35))
            theCase.zPosition = 1
            addChild(theCase)
            cases.addObject(theCase)
        }
        if gametype == StartScene.GAMETYPE_SOLO {
            label.text = NSLocalizedString("game.score.no", comment: "No points")
        } else if gametype == StartScene.GAMETYPE_COMPUTER {
            label.text = NSLocalizedString("game.score.vsc.no.no", comment: "No points both")
        } else if gametype == StartScene.GAMETYPE_TIMED {
            label.text = String(format: NSLocalizedString("game.time", comment: "Time"), 0)
        }
        label.fontColor = SKColor.blackColor()
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            label.fontSize = 12
        } else {
            label.fontSize = 30
        }
        label.fontName = "Verdana-Bold"
        label.position = CGPointMake(label.frame.width/2, 5)
        label.zPosition = 2
        addChild(label)
        winCaseNumber = Int(arc4random_uniform(UInt32(width) * UInt32(height)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func breakBaloon(index:Int, touch:CGPoint, computer:Bool) {
        if waitingForComputer && !computer {
            return
        }
        if beginTime == nil {
            beginTime = NSDate().timeIntervalSince1970
        }
        if (cases.objectAtIndex(index) as! Case).breaked {
            return
        }
        (cases.objectAtIndex(index) as! Case).breakBaloon(index == winCaseNumber)
        var data:NSData
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
            label.position = CGPointMake(label.frame.width/2, 5)
            let plus = SKLabelNode(text: "+ 1")
            if computer {
                plus.fontColor = SKColor.redColor()
            } else {
                plus.fontColor = SKColor.blueColor()
            }
            plus.fontName = "Verdana-Bold"
            plus.fontSize = 25
            plus.position = touch
            plus.zPosition = 3
            addChild(plus)
            plus.runAction(SKAction.sequence([SKAction.waitForDuration(NSTimeInterval(5)), SKAction.removeFromParent()]))
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
            } while (cases.objectAtIndex(winCaseNumber) as! Case).breaked && !gameEnded
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
            (cases.objectAtIndex(index) as! Case).baloonBreaked()
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
            self.runAction(SKAction.sequence([SKAction.waitForDuration(NSTimeInterval(0.25)), SKAction.runBlock({
                var wherebreak:Int
                repeat {
                    wherebreak = Int(arc4random_uniform(UInt32(self.width) * UInt32(self.height)))
                } while (self.cases.objectAtIndex(wherebreak) as! Case).breaked
                self.breakBaloon(wherebreak, touch: self.cases.objectAtIndex(wherebreak).position, computer: true)
                self.waitingForComputer = false
            })]))
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let point = touch.locationInNode(self)
            if self.nodeAtPoint(point) is Case {
                breakBaloon((self.nodeAtPoint(point) as! Case).index, touch: point, computer: false)
            }
        }
    }
    
    func gameEnd() {
        endTime = NSDate().timeIntervalSince1970 - beginTime!
        if self.gametype == StartScene.GAMETYPE_COMPUTER {
            if self.points > self.computerpoints {
                label.text = String(format: NSLocalizedString("game.score.vsc.end.won", comment: "Points at end"), self.points, self.computerpoints)
            } else if self.computerpoints > self.points {
                label.text = String(format: NSLocalizedString("game.score.vsc.end.lost", comment: "Points at end"), self.computerpoints, self.points)
            } else {
                label.text = String(format: NSLocalizedString("game.score.vsc.end.same", comment: "Points at end"), self.points)
            }
            label.position = CGPointMake(label.frame.width/2, 5)
        } else if self.gametype == StartScene.GAMETYPE_TIMED {
            points = Int((Float(width * height) / Float(endTime!)) * 5)
            label.text = String(format: NSLocalizedString("game.score.time", comment: "Points at end"), self.points, Int(self.endTime!))
            label.position = CGPointMake(label.frame.width/2, 5)
        }
        let newRecord = self.gametype == StartScene.GAMETYPE_SOLO && NSUserDefaults.standardUserDefaults().integerForKey("highscore") < self.points || self.gametype == StartScene.GAMETYPE_TIMED && NSUserDefaults.standardUserDefaults().integerForKey("bestTimedScore") < self.points
        label.runAction(SKAction.sequence([SKAction.waitForDuration(NSTimeInterval(0.5)), SKAction.runBlock({
            self.label.fontColor = SKColor.orangeColor()
        }), SKAction.waitForDuration(NSTimeInterval(1)), SKAction.runBlock({
            self.label.fontColor = SKColor.blackColor()
            if newRecord {
                let record = SKLabelNode(text: NSLocalizedString("game.end.newrecord", comment: ""))
                record.fontColor = SKColor.orangeColor()
                record.fontName = "Verdana-Bold"
                record.fontSize = 25
                record.zPosition = 1000
                record.position = CGPointMake(self.frame.midX, self.frame.midY)
                self.addChild(record)
            }
        }), SKAction.waitForDuration(NSTimeInterval(newRecord ? 1.5 : 0.5)), SKAction.runBlock({
            let data = NSUserDefaults.standardUserDefaults()
            if self.gametype == StartScene.GAMETYPE_SOLO && data.integerForKey("highscore") < self.points {
                data.setInteger(self.points, forKey: "highscore")
            } else if self.gametype == StartScene.GAMETYPE_TIMED && data.integerForKey("bestTimedScore") < self.points {
                data.setInteger(self.points, forKey: "bestTimedScore")
            }
            let gvc = self.view!.window!.rootViewController as! GameViewController
            gvc.currentGame = nil
            let levelModifier = Float(max(10 - GameViewController.getLevel(), 1))
            let sizeModifier = Float(self.width * self.height) / 100
            gvc.addXP(Int(5 * levelModifier * sizeModifier))
            let scene:StartScene = StartScene(size: self.frame.size)
            scene.lastGameInfo = self.label.text!
            self.view!.presentScene(scene, transition: SKTransition.flipVerticalWithDuration(NSTimeInterval(1)))
        })]))
    }
    
    override func update(currentTime: NSTimeInterval) {
        if gametype == StartScene.GAMETYPE_TIMED && endTime == nil && !isGamePaused() {
            label.text = String(format: NSLocalizedString("game.time", comment: "Time"), (beginTime == nil ? 0 : Int(NSDate().timeIntervalSince1970 - beginTime!)))
            label.position = CGPointMake(label.frame.width/2, 5)
        }
    }
}