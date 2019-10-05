//
//  GameScene.swift
//  BreakBaloon
//
//  Created by Emil on 19/06/2016.
//  Copyright (c) 2016 Snowy_1803. All rights reserved.
//

import SpriteKit

class StartScene: SKScene {
    let BUTTON_FONT = "ChalkboardSE-Light"
    static let GAMETYPE_SOLO:Int8 = 0
    static let GAMETYPE_COMPUTER:Int8 = 1
    static let GAMETYPE_TIMED:Int8 = 2
    static let GAMETYPE_RAND:Int8 = 3
    let buttonTexture = SKTexture(imageNamed: "buttonbg")
    let minibuttonTexture = SKTexture(imageNamed: "buttonminibg")
    
    var bbLabel = SKLabelNode()
    var cLabel = SKLabelNode()
    var hsLabel = SKLabelNode()
    var bsLabel = SKLabelNode()
    
    var soloButton = SKSpriteNode()
    var multiButton = SKSpriteNode()
    var timedButton = SKSpriteNode()
    var randButton = SKSpriteNode()
    var smallButton = SKSpriteNode()
    var mediumButton = SKSpriteNode()
    var bigButton = SKSpriteNode()
    var adaptButton = SKSpriteNode()
    var prefsButton = SKSpriteNode()
    var bbstoreButton = SKSpriteNode()
    
    var tsoloButton = SKLabelNode()
    var tmultiButton = SKLabelNode()
    var ttimedButton = SKLabelNode()
    var trandButton = SKLabelNode()
    var tsmallButton = SKLabelNode()
    var tmediumButton = SKLabelNode()
    var tbigButton = SKLabelNode()
    var tadaptButton = SKLabelNode()
    var tprefsButton = SKLabelNode()
    var tbbstoreButton = SKLabelNode()
    
    var xpLabel = SKShapeNode()
    var txpLabel = SKLabelNode()
    
    var actualPane:Int = 0
    var touchesBegan:CGPoint?
    var gametype:Int8 = -1
    var lastGameInfo:String?
    
    override convenience init(size:CGSize) {
        self.init(size: size, growXPFrom: -1)
    }
    
    init(size:CGSize, growXPFrom: CGFloat) {
        super.init(size: size)
        self.backgroundColor = SKColor.brown
        self.isPaused = true
        initFirstPane(false)
        
        if UIDevice.current.userInterfaceIdiom != .phone {
            bbLabel.text = "BreakBaloon"
            bbLabel.fontSize = 45
            bbLabel.fontName = "Chalkduster"
            bbLabel.fontColor = SKColor.white
            self.addChild(bbLabel)
        }
        cLabel.text = "© Snowy_1803"
        cLabel.fontSize = 10
        cLabel.fontName = "ChalkboardSE-Regular"
        cLabel.fontColor = SKColor.white
        self.addChild(cLabel)
        hsLabel.text = String(format: NSLocalizedString("highscore.score", comment: "Highscore"), UserDefaults.standard.integer(forKey: "highscore"))
        hsLabel.fontSize = 25
        hsLabel.fontName = "ChalkboardSE-Regular"
        hsLabel.fontColor = SKColor.orange
        self.addChild(hsLabel)
        bsLabel.text = String(format: NSLocalizedString("highscore.time", comment: "Best timed score"), UserDefaults.standard.integer(forKey: "bestTimedScore"))
        bsLabel.fontSize = 25
        bsLabel.fontName = "ChalkboardSE-Regular"
        bsLabel.fontColor = SKColor.orange
        self.addChild(bsLabel)
        print(growXPFrom > -1 ? growXPFrom : CGFloat(GameViewController.getLevelXPFloat()))
        xpLabel = SKShapeNode(rect: CGRect(x: 0, y: 0, width: (growXPFrom > -1 ? growXPFrom : CGFloat(GameViewController.getLevelXPFloat())) * size.width, height: 15))
        xpLabel.fillColor = SKColor(red: 0, green: 0.5, blue: 1, alpha: 1)
        xpLabel.strokeColor = SKColor.clear
        xpLabel.zPosition = 2
        self.addChild(xpLabel)
        if growXPFrom > -1 {
            print("GrowXP: \(growXPFrom) -> \(GameViewController.getLevelXPFloat())")
            xpLabel.run(SKAction.sequence([SKAction.wait(forDuration: 0.1), SKAction.scaleX(to: CGFloat(GameViewController.getLevelXPFloat()) / growXPFrom, duration: 1.0)]), completion: {() -> Void in
                    self.xpLabel.removeFromParent()
                    self.xpLabel = SKShapeNode(rect: CGRect(x: 0, y: 0, width: CGFloat(GameViewController.getLevelXPFloat()) * size.width, height: 15))
                    self.xpLabel.fillColor = SKColor(red: 0, green: 0.5, blue: 1, alpha: 1)
                    self.xpLabel.strokeColor = SKColor.clear
                    self.xpLabel.zPosition = 2
                    self.addChild(self.xpLabel)
                })
        }
        txpLabel = SKLabelNode(text: String(format: NSLocalizedString("level.label", comment: "Level x"), GameViewController.getLevel()))
        txpLabel.fontSize = 13
        txpLabel.fontName = "AppleSDGothicNeo-Bold"
        txpLabel.fontColor = SKColor.white
        txpLabel.zPosition = 3
        self.addChild(txpLabel)
        adjustPosition(false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initFirstPane(_ cancelled:Bool) {
        soloButton = SKSpriteNode(texture: buttonTexture)
        soloButton.zPosition = 1
        self.addChild(soloButton)
        tsoloButton.text = NSLocalizedString("gametype.singleplayer", comment: "Singleplayer")
        tsoloButton.fontSize = 35
        tsoloButton.fontName = BUTTON_FONT
        tsoloButton.fontColor = SKColor.black
        tsoloButton.zPosition = 2
        self.addChild(tsoloButton)
        
        multiButton = SKSpriteNode(texture: buttonTexture)
        multiButton.zPosition = 1
        self.addChild(multiButton)
        tmultiButton.text = NSLocalizedString("gametype.computer", comment: "Versus computer")
        tmultiButton.fontSize = 35
        tmultiButton.fontName = BUTTON_FONT
        tmultiButton.fontColor = SKColor.black
        tmultiButton.zPosition = 2
        self.addChild(tmultiButton)
        
        timedButton = SKSpriteNode(texture: buttonTexture)
        timedButton.zPosition = 1
        self.addChild(timedButton)
        ttimedButton.text = NSLocalizedString("gametype.timed", comment: "Timed game")
        ttimedButton.fontSize = 35
        ttimedButton.fontName = BUTTON_FONT
        ttimedButton.fontColor = SKColor.black
        ttimedButton.zPosition = 2
        self.addChild(ttimedButton)
        
        randButton = SKSpriteNode(texture: buttonTexture)
        randButton.zPosition = 1
        if GameViewController.getLevel() < RandGameScene.REQUIREMENT {
            grey(randButton)
            let level = SKSpriteNode(imageNamed: "level")
            level.position = CGPoint(x: min(randButton.frame.width / 2, self.frame.width / 2) - 30, y: randButton.frame.midY)
            print(level.position)
            level.zPosition = 1
            level.setScale(1.5)
            randButton.addChild(level)
            let tlevel = SKLabelNode(text: "\(RandGameScene.REQUIREMENT)")
            tlevel.position = CGPoint(x: min(randButton.frame.width / 2, self.frame.width / 2) - 30, y: randButton.frame.midY - 12)
            tlevel.fontName = "AppleSDGothicNeo-Bold"
            tlevel.fontSize = 24
            tlevel.fontColor = SKColor.white
            tlevel.zPosition = 2
            randButton.addChild(tlevel)
        }
        self.addChild(randButton)
        trandButton.text = NSLocalizedString("gametype.rand", comment: "Game with random baloons spawning")
        trandButton.fontSize = 35
        trandButton.fontName = BUTTON_FONT
        trandButton.fontColor = SKColor.black
        trandButton.zPosition = 2
        self.addChild(trandButton)
        
        prefsButton = SKSpriteNode(texture: minibuttonTexture)
        prefsButton.zPosition = 1
        self.addChild(prefsButton)
        tprefsButton.text = NSLocalizedString("settings.title", comment: "Settings")
        tprefsButton.fontSize = 20
        tprefsButton.fontName = BUTTON_FONT
        tprefsButton.fontColor = SKColor.black
        tprefsButton.zPosition = 2
        self.addChild(tprefsButton)
        
        bbstoreButton = SKSpriteNode(texture: minibuttonTexture)
        bbstoreButton.zPosition = 1
        self.addChild(bbstoreButton)
        tbbstoreButton.text = NSLocalizedString("bbstore.button", comment: "BBStore")
        tbbstoreButton.fontSize = 20
        tbbstoreButton.fontName = BUTTON_FONT
        tbbstoreButton.fontColor = SKColor.black
        tbbstoreButton.zPosition = 2
        self.addChild(tbbstoreButton)

        actualPane = 1;
        adjustPosition(cancelled)
    }
    
    func adjustPosition(_ cancelled:Bool, sizeChange:Bool = false) {
        if UIDevice.current.userInterfaceIdiom != .phone {
            bbLabel.position = CGPoint(x: self.frame.midX, y: 40)
            hsLabel.position = CGPoint(x: self.frame.midX, y: 120)
            bsLabel.position = CGPoint(x: self.frame.midX, y: 95)
        } else {
            hsLabel.position = CGPoint(x: self.frame.midX, y: 70)
            bsLabel.position = CGPoint(x: self.frame.midX, y: 45)
        }
        cLabel.position = CGPoint(x: self.frame.midX, y: 20)
        xpLabel.path = CGPath(rect: CGRect(x: 0, y: 0, width: CGFloat(GameViewController.getLevelXPFloat()) * size.width, height: 15), transform: nil)
        txpLabel.position = CGPoint(x: size.width / 2, y: 0)
        if actualPane == 1 {
            soloButton.position = CGPoint(x: cancelled ? -soloButton.size.width : self.frame.midX, y: getPositionYForButton(0, text: false))
            multiButton.position = CGPoint(x: cancelled ? -multiButton.size.width : self.frame.midX, y: getPositionYForButton(1, text: false))
            timedButton.position = CGPoint(x: cancelled ? -timedButton.size.width : self.frame.midX, y: getPositionYForButton(2, text: false))
            randButton.position = CGPoint(x: cancelled ? -randButton.size.width : self.frame.midX, y: getPositionYForButton(3, text: false))
            prefsButton.position = CGPoint(x: cancelled ? -prefsButton.size.width : self.frame.width / 4, y: 170 - lowerButtonMinus())
            bbstoreButton.position = CGPoint(x: cancelled ? -bbstoreButton.size.width : self.frame.width / 4 * 3, y: 170 - lowerButtonMinus())
            
            tsoloButton.position = CGPoint(x: cancelled ? -soloButton.size.width : self.frame.midX, y: getPositionYForButton(0, text: true))
            tmultiButton.position = CGPoint(x: cancelled ? -multiButton.size.width : self.frame.midX, y: getPositionYForButton(1, text: true))
            ttimedButton.position = CGPoint(x: cancelled ? -timedButton.size.width : self.frame.midX, y: getPositionYForButton(2, text: true))
            trandButton.position = CGPoint(x: cancelled ? -randButton.size.width : self.frame.midX, y: getPositionYForButton(3, text: true))
            tprefsButton.position = CGPoint(x: cancelled ? -prefsButton.size.width : self.frame.width / 4, y: 160 - lowerButtonMinus())
            tbbstoreButton.position = CGPoint(x: cancelled ? -bbstoreButton.size.width : self.frame.width / 4 * 3, y: 160 - lowerButtonMinus())
        } else if actualPane == 2 {
            smallButton.position = CGPoint(x: sizeChange ? self.frame.midX : self.frame.size.width + smallButton.size.width, y: getPositionYForButton(0, text: false))
            mediumButton.position = CGPoint(x: sizeChange ? self.frame.midX : self.frame.size.width + mediumButton.size.width, y: getPositionYForButton(1, text: false))
            bigButton.position = CGPoint(x: sizeChange ? self.frame.midX : self.frame.size.width + bigButton.size.width, y: getPositionYForButton(2, text: false))
            adaptButton.position = CGPoint(x: sizeChange ? self.frame.midX : self.frame.size.width + adaptButton.size.width, y: getPositionYForButton(3, text: false))
            
            tsmallButton.position = CGPoint(x: sizeChange ? self.frame.midX : self.frame.size.width + smallButton.size.width, y: getPositionYForButton(0, text: true))
            tmediumButton.position = CGPoint(x: sizeChange ? self.frame.midX : self.frame.size.width + mediumButton.size.width, y: getPositionYForButton(1, text: true))
            tbigButton.position = CGPoint(x: sizeChange ? self.frame.midX : self.frame.size.width + bigButton.size.width, y: getPositionYForButton(2, text: true))
            tadaptButton.position = CGPoint(x: sizeChange ? self.frame.midX : self.frame.size.width + adaptButton.size.width, y: getPositionYForButton(3, text: true))
        } else if actualPane == 3 {
            if sizeChange {
                for child in children {
                    if child is RandGameLevelNode {
                        child.removeFromParent()
                    }
                }
                initThirdPane()
            }
            for child in children {
                if child is RandGameLevelNode {
                    child.position = CGPoint(x: sizeChange ? (child as! RandGameLevelNode).realPosition.x : self.frame.size.width + adaptButton.size.width, y: (child as! RandGameLevelNode).realPosition.y)
                }
            }
            
        } else {
            //return false
        }
        //return true
    }
    
    func lowerButtonMinus() -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return 50
        }
        return 0
    }
    
    func initSecondPane() {
        smallButton = SKSpriteNode(texture: buttonTexture)
        smallButton.zPosition = 1
        greyIfNotFill(smallButton, size: 5)
        self.addChild(smallButton)
        tsmallButton = SKLabelNode()
        tsmallButton.text = NSLocalizedString("gamesize.small", comment: "Small")
        tsmallButton.fontSize = 35
        tsmallButton.fontName = BUTTON_FONT
        tsmallButton.fontColor = SKColor.black
        tsmallButton.zPosition = 2
        self.addChild(tsmallButton)
        
        mediumButton = SKSpriteNode(texture: buttonTexture)
        mediumButton.zPosition = 1
        greyIfNotFill(mediumButton, size: 7)
        self.addChild(mediumButton)
        tmediumButton = SKLabelNode()
        tmediumButton.text = NSLocalizedString("gamesize.medium", comment: "Normal")
        tmediumButton.fontSize = 35
        tmediumButton.fontName = BUTTON_FONT
        tmediumButton.fontColor = SKColor.black
        tmediumButton.zPosition = 2
        self.addChild(tmediumButton)
        
        bigButton = SKSpriteNode(texture: buttonTexture)
        bigButton.zPosition = 1
        greyIfNotFill(bigButton, size: 10)
        self.addChild(bigButton)
        tbigButton = SKLabelNode()
        tbigButton.text = NSLocalizedString("gamesize.large", comment: "Large")
        tbigButton.fontSize = 35
        tbigButton.fontName = BUTTON_FONT
        tbigButton.fontColor = SKColor.black
        tbigButton.zPosition = 2
        self.addChild(tbigButton)
        
        adaptButton = SKSpriteNode(texture: buttonTexture)
        adaptButton.zPosition = 1
        self.addChild(adaptButton)
        tadaptButton = SKLabelNode()
        tadaptButton.text = String(format: NSLocalizedString("gamesize.adaptive", comment: "Adaptive"), Int(self.frame.size.width / 75), Int((self.frame.size.height - 35) / 75))
        tadaptButton.fontSize = 35
        tadaptButton.fontName = BUTTON_FONT
        tadaptButton.fontColor = SKColor.black
        tadaptButton.zPosition = 2
        self.addChild(tadaptButton)
        
        actualPane = 2
        adjustPosition(false)
    }
    
    func initThirdPane() {
        let w = Int(self.frame.size.width / 75)
        for i in 0..<RandGameLevel.levels.count {
            let node = RandGameLevel.levels[i].createNode()
            node.realPosition = CGPoint(x: CGFloat(i % w * 75 + 35), y: self.frame.size.height - CGFloat(i / w * 75 + 35))
            addChild(node)
        }
        
        actualPane = 3;
        adjustPosition(false)
    }
    
    func grey(_ sprite:SKSpriteNode) {
        sprite.color = SKColor.gray
        sprite.colorBlendFactor = 0.5
    }
    
    func greyIfNotFill(_ sprite:SKSpriteNode, size:Int) {
        if Int(self.frame.size.width / 75) < size || Int((self.frame.size.height - 20) / 75) < size {
            grey(sprite)
        }
    }
    
    func getPositionYForButton(_ indexFromTop:Int, text:Bool) -> CGFloat {
        var position:CGFloat = 0
        let height = buttonTexture.size().height
        if UIDevice.current.userInterfaceIdiom == .pad {
            if indexFromTop == 0 {
                position = self.frame.size.height - height/2
            } else if indexFromTop == 1 {
                position = self.frame.size.height - height*2
            } else {
                position = self.frame.size.height - height*(2 + 1.5*CGFloat(indexFromTop - 1))
            }
        } else {
            position = self.frame.size.height - height*CGFloat(indexFromTop)
        }
        return text ? position - 45 : position - 30
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 1 {
            touchesBegan = touches.first?.location(in: self)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 1 {
            let point:CGPoint = (touches.first?.location(in: self))!
            if !(touchesBegan!.x <= point.x + 10 && touchesBegan!.x >= point.x - 10 && touchesBegan!.y <= point.y + 10 && touchesBegan!.y >= point.y - 10) || actualPane == -1 {
                if touchesBegan!.x < point.x - 100 {
                    cancelScreen()
                }
            } else if onNode(soloButton, point: point) {
                gametype = StartScene.GAMETYPE_SOLO
                transitionFirstToSecond()
            } else if onNode(multiButton, point: point) {
                gametype = StartScene.GAMETYPE_COMPUTER
                transitionFirstToSecond()
            } else if onNode(timedButton, point: point) {
                gametype = StartScene.GAMETYPE_TIMED
                transitionFirstToSecond()
            } else if onNode(randButton, point: point) {
                if GameViewController.getLevel() >= RandGameScene.REQUIREMENT {
                    transitionFirstToThird()
                }
            } else if onNode(smallButton, point: point) {
                if smallButton.colorBlendFactor != 0.5 {
                    newGame(gametype, width: 5, height: 5)
                } else {
                    showResolutionAlert()
                }
            } else if onNode(mediumButton, point: point) {
                if smallButton.colorBlendFactor != 0.5 {
                    newGame(gametype, width: 7, height: 7)
                } else {
                    showResolutionAlert()
                }
            } else if onNode(bigButton, point: point) {
                if smallButton.colorBlendFactor != 0.5 {
                    newGame(gametype, width: 10, height: 10)
                } else {
                    showResolutionAlert()
                }
            } else if onNode(adaptButton, point: point) {
                newGame(gametype, width: UInt(self.frame.size.width / 75), height: UInt((self.frame.size.height - 20) / 75))
            } else if onNode(prefsButton, point: point) {
                if littleScreen() {
                    self.view?.presentScene(IPhoneSettingScene(previous: self), transition: SKTransition.doorsOpenHorizontal(withDuration: TimeInterval(1)))
                } else {
                    self.view?.presentScene(SettingScene(previous: self), transition: SKTransition.doorsOpenHorizontal(withDuration: TimeInterval(1)))
                }
            } else if onNode(bbstoreButton, point: point) {
                self.view?.presentScene(BBStoreScene(start: self), transition: SKTransition.doorsCloseVertical(withDuration: TimeInterval(1)))
            } else if actualPane == 3 {
                for child in children {
                    if child is RandGameLevelNode && onNode(child, point: point) {
                        (child as! RandGameLevelNode).click(self.view!)
                        break
                    }
                }
            }
        }
    }
    
    func littleScreen() -> Bool {
        return self.frame.height < 575
    }
    
    func showDialog(_ title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.view!.window!.rootViewController!.present(alert, animated: true, completion: nil)
    }
    
    func showResolutionAlert() {
        showDialog(NSLocalizedString("error", comment: "error"), message: NSLocalizedString("gamesize.error", comment: "++ resolution"))
    }
    
    func showLevelAlert() {
        showDialog(NSLocalizedString("error", comment: "error"), message: NSLocalizedString("gametype.error", comment: "play to unlock"))
    }
    
    func newGame(_ gametype:Int8, width:UInt, height:UInt) {
        self.view?.presentScene(GameScene(view: self.view!, gametype: gametype, width: width, height: height), transition: SKTransition.flipVertical(withDuration: TimeInterval(1)));
    }
    
    func cancelScreen() {
        if actualPane == 2 {
            transitionSecondToFirst()
        } else if actualPane == 3 {
            transitionThirdToFirst()
        } else if actualPane == 1 && lastGameInfo != nil {
            showDialog(NSLocalizedString("gameinfo.title", comment: "Last game information"), message: lastGameInfo!)
        }
    }
    
    func transitionFirstToSecond() {
        actualPane = -1
        transitionQuit(soloButton, relativeTo: soloButton)
        transitionQuit(multiButton, relativeTo: multiButton)
        transitionQuit(timedButton, relativeTo: timedButton)
        transitionQuit(randButton, relativeTo: randButton)
        transitionQuit(prefsButton, relativeTo: prefsButton)
        transitionQuit(bbstoreButton, relativeTo: bbstoreButton)
        transitionQuit(tsoloButton, relativeTo: soloButton)
        transitionQuit(tmultiButton, relativeTo: multiButton)
        transitionQuit(ttimedButton, relativeTo: timedButton)
        transitionQuit(trandButton, relativeTo: randButton)
        transitionQuit(tprefsButton, relativeTo: prefsButton)
        transitionQuit(tbbstoreButton, relativeTo: bbstoreButton)
        initSecondPane()
        actualPane = -1
        transitionJoinCenter(smallButton)
        transitionJoinCenter(mediumButton)
        transitionJoinCenter(bigButton)
        transitionJoinCenter(adaptButton)
        transitionJoinCenter(tsmallButton)
        transitionJoinCenter(tmediumButton)
        transitionJoinCenter(tbigButton)
        transitionJoinCenter(tadaptButton)
        self.run(SKAction.sequence([SKAction.wait(forDuration: TimeInterval(0.5)), SKAction.run({
            self.actualPane = 2;
        })]))
    }
    
    func transitionFirstToThird() {
        actualPane = -1
        transitionQuit(soloButton, relativeTo: soloButton)
        transitionQuit(multiButton, relativeTo: multiButton)
        transitionQuit(timedButton, relativeTo: timedButton)
        transitionQuit(randButton, relativeTo: randButton)
        transitionQuit(prefsButton, relativeTo: prefsButton)
        transitionQuit(bbstoreButton, relativeTo: bbstoreButton)
        transitionQuit(tsoloButton, relativeTo: soloButton)
        transitionQuit(tmultiButton, relativeTo: multiButton)
        transitionQuit(ttimedButton, relativeTo: timedButton)
        transitionQuit(trandButton, relativeTo: randButton)
        transitionQuit(tprefsButton, relativeTo: prefsButton)
        transitionQuit(tbbstoreButton, relativeTo: bbstoreButton)
        initThirdPane()
        actualPane = -1
        for child in children {
            if child is RandGameLevelNode {
                child.run(SKAction.move(to: (child as! RandGameLevelNode).realPosition, duration: TimeInterval(0.5)))
            }
        }
        self.run(SKAction.sequence([SKAction.wait(forDuration: TimeInterval(0.5)), SKAction.run({
            self.actualPane = 3;
        })]))
    }
    
    func transitionSecondToFirst() {
        actualPane = -1
        transitionQuitRight(smallButton, relativeTo: smallButton)
        transitionQuitRight(mediumButton, relativeTo: mediumButton)
        transitionQuitRight(bigButton, relativeTo: bigButton)
        transitionQuitRight(adaptButton, relativeTo: adaptButton)
        transitionQuitRight(tsmallButton, relativeTo: smallButton)
        transitionQuitRight(tmediumButton, relativeTo: mediumButton)
        transitionQuitRight(tbigButton, relativeTo: bigButton)
        transitionQuitRight(tadaptButton, relativeTo: adaptButton)
        initFirstPane(true)
        actualPane = -1
        transitionJoinCenter(soloButton)
        transitionJoinCenter(multiButton)
        transitionJoinCenter(timedButton)
        transitionJoinCenter(randButton)
        transitionJoinAt(prefsButton, at: CGPoint(x: self.frame.width / 4, y: 170))
        transitionJoinAt(bbstoreButton, at: CGPoint(x: self.frame.width / 4 * 3, y: 170))
        transitionJoinCenter(tsoloButton)
        transitionJoinCenter(tmultiButton)
        transitionJoinCenter(ttimedButton)
        transitionJoinCenter(trandButton)
        transitionJoinAt(tprefsButton, at: CGPoint(x: self.frame.width / 4, y: 160))
        transitionJoinAt(tbbstoreButton, at: CGPoint(x: self.frame.width / 4 * 3, y: 160))
        self.run(SKAction.sequence([SKAction.wait(forDuration: TimeInterval(0.5)), SKAction.run({
            self.actualPane = 1;
        })]))
    }
    
    func transitionThirdToFirst() {
        actualPane = -1
        for child in children {
            if child is RandGameLevelNode {
                transitionQuitRight(child, relativeTo: child)
            }
        }
        initFirstPane(true)
        actualPane = -1
        transitionJoinCenter(soloButton)
        transitionJoinCenter(multiButton)
        transitionJoinCenter(timedButton)
        transitionJoinCenter(randButton)
        transitionJoinAt(prefsButton, at: CGPoint(x: self.frame.width / 4, y: 170))
        transitionJoinAt(bbstoreButton, at: CGPoint(x: self.frame.width / 4 * 3, y: 170))
        transitionJoinCenter(tsoloButton)
        transitionJoinCenter(tmultiButton)
        transitionJoinCenter(ttimedButton)
        transitionJoinCenter(trandButton)
        transitionJoinAt(tprefsButton, at: CGPoint(x: self.frame.width / 4, y: 160))
        transitionJoinAt(tbbstoreButton, at: CGPoint(x: self.frame.width / 4 * 3, y: 160))
        self.run(SKAction.sequence([SKAction.wait(forDuration: TimeInterval(0.5)), SKAction.run({
            self.actualPane = 1;
        })]))
    }
    
    func transitionQuit(_ node:SKNode, relativeTo:SKNode) {
        let actionArray:[SKAction] = [SKAction] (arrayLiteral: SKAction.move(to: CGPoint(x: -relativeTo.frame.width/2, y: node.position.y), duration: TimeInterval(0.5)),SKAction.removeFromParent())
        node.run(SKAction.sequence(actionArray))
    }
    
    func transitionJoinCenter(_ node:SKNode) {
        node.run(SKAction.move(to: CGPoint(x: self.frame.width/2, y: node.position.y), duration: TimeInterval(0.5)))
    }
    
    func transitionJoinAt(_ node:SKNode, at:CGPoint) {
        node.run(SKAction.move(to: at, duration: TimeInterval(0.5)))
    }
    
    func transitionQuitRight(_ node:SKNode, relativeTo:SKNode) {
        let actionArray:[SKAction] = [SKAction] (arrayLiteral: SKAction.move(to: CGPoint(x: self.frame.width + relativeTo.frame.width/2, y: node.position.y), duration: TimeInterval(0.5)),SKAction.removeFromParent())
        node.run(SKAction.sequence(actionArray))
    }
    
    func onNode(_ node:SKNode, point:CGPoint) -> Bool {
        return node.frame.contains(point)
    }
   
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        if isPaused {
            isPaused = false
        }
    }
}
