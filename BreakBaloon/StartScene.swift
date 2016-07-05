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
    let buttonTexture = SKTexture(imageNamed: "buttonbg")
    let minibuttonTexture = SKTexture(imageNamed: "buttonminibg")
    
    var bbLabel = SKLabelNode()
    var cLabel = SKLabelNode()
    var hsLabel = SKLabelNode()
    var bsLabel = SKLabelNode()
    
    var soloButton = SKSpriteNode()
    var multiButton = SKSpriteNode()
    var timedButton = SKSpriteNode()
    var smallButton = SKSpriteNode()
    var mediumButton = SKSpriteNode()
    var bigButton = SKSpriteNode()
    var adaptButton = SKSpriteNode()
    var prefsButton = SKSpriteNode()
    var bbstoreButton = SKSpriteNode()
    
    var tsoloButton = SKLabelNode()
    var tmultiButton = SKLabelNode()
    var ttimedButton = SKLabelNode()
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
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        /*let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "BreakBaloon"
        myLabel.fontSize = 45
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        
        self.addChild(myLabel)*/
    }
    
    override init(size:CGSize) {
        super.init(size: size)
        self.backgroundColor = SKColor.brownColor()
        initFirstPane(false)
        
        bbLabel = SKLabelNode()
        bbLabel.text = "BreakBaloon"
        bbLabel.fontSize = 45
        bbLabel.fontName = "Chalkduster"
        bbLabel.fontColor = SKColor.whiteColor()
        self.addChild(bbLabel)
        cLabel = SKLabelNode()
        cLabel.text = "© Snowy_1803"
        cLabel.fontSize = 10
        cLabel.fontName = "ChalkboardSE-Regular"
        cLabel.fontColor = SKColor.whiteColor()
        self.addChild(cLabel)
        hsLabel = SKLabelNode()
        hsLabel.text = String(format: NSLocalizedString("highscore.score", comment: "Highscore"), NSUserDefaults.standardUserDefaults().integerForKey("highscore"))
        hsLabel.fontSize = 25
        hsLabel.fontName = "ChalkboardSE-Regular"
        hsLabel.fontColor = SKColor.orangeColor()
        self.addChild(hsLabel)
        bsLabel = SKLabelNode()
        bsLabel.text = String(format: NSLocalizedString("highscore.time", comment: "Best timed score"), NSUserDefaults.standardUserDefaults().integerForKey("bestTimedScore"))
        bsLabel.fontSize = 25
        bsLabel.fontName = "ChalkboardSE-Regular"
        bsLabel.fontColor = SKColor.orangeColor()
        self.addChild(bsLabel)
        xpLabel = SKShapeNode(rect: CGRect(x: 0, y: 0, width: CGFloat(GameViewController.getLevelXPFloat()) * size.width, height: 15))
        xpLabel.fillColor = SKColor(red: 0, green: 0.5, blue: 1, alpha: 1)
        xpLabel.strokeColor = SKColor.clearColor()
        xpLabel.zPosition = 2
        self.addChild(xpLabel)
        txpLabel = SKLabelNode(text: String(format: NSLocalizedString("level.label", comment: "Level x"), GameViewController.getLevel()))
        txpLabel.fontSize = 13
        txpLabel.fontName = "AppleSDGothicNeo-Bold"
        txpLabel.fontColor = SKColor.whiteColor()
        txpLabel.zPosition = 3
        self.addChild(txpLabel)
        adjustPosition(false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initFirstPane(cancelled:Bool) {
        soloButton = SKSpriteNode(texture: buttonTexture)
        soloButton.zPosition = 1
        self.addChild(soloButton)
        tsoloButton.text = NSLocalizedString("gametype.singleplayer", comment: "Singleplayer")
        tsoloButton.fontSize = 35
        tsoloButton.fontName = BUTTON_FONT
        tsoloButton.fontColor = SKColor.blackColor()
        tsoloButton.zPosition = 2
        self.addChild(tsoloButton)
        
        multiButton = SKSpriteNode(texture: buttonTexture)
        multiButton.zPosition = 1
        self.addChild(multiButton)
        tmultiButton.text = NSLocalizedString("gametype.computer", comment: "Versus computer")
        tmultiButton.fontSize = 35
        tmultiButton.fontName = BUTTON_FONT
        tmultiButton.fontColor = SKColor.blackColor()
        tmultiButton.zPosition = 2
        self.addChild(tmultiButton)
        
        timedButton = SKSpriteNode(texture: buttonTexture)
        timedButton.zPosition = 1
        self.addChild(timedButton)
        ttimedButton.text = NSLocalizedString("gametype.timed", comment: "Timed game")
        ttimedButton.fontSize = 35
        ttimedButton.fontName = BUTTON_FONT
        ttimedButton.fontColor = SKColor.blackColor()
        ttimedButton.zPosition = 2
        self.addChild(ttimedButton)
        
        prefsButton = SKSpriteNode(texture: minibuttonTexture)
        prefsButton.zPosition = 1
        self.addChild(prefsButton)
        tprefsButton.text = NSLocalizedString("settings.title", comment: "Settings")
        tprefsButton.fontSize = 20
        tprefsButton.fontName = BUTTON_FONT
        tprefsButton.fontColor = SKColor.blackColor()
        tprefsButton.zPosition = 2
        self.addChild(tprefsButton)
        
        bbstoreButton = SKSpriteNode(texture: minibuttonTexture)
        bbstoreButton.zPosition = 1
        self.addChild(bbstoreButton)
        tbbstoreButton.text = NSLocalizedString("bbstore.button", comment: "BBStore")
        tbbstoreButton.fontSize = 20
        tbbstoreButton.fontName = BUTTON_FONT
        tbbstoreButton.fontColor = SKColor.blackColor()
        tbbstoreButton.zPosition = 2
        self.addChild(tbbstoreButton)

        actualPane = 1;
        adjustPosition(cancelled)
    }
    
    func adjustPosition(cancelled:Bool) -> Bool {
        bbLabel.position = CGPointMake(CGRectGetMidX(self.frame), 40)
        cLabel.position = CGPointMake(CGRectGetMidX(self.frame), 20)
        hsLabel.position = CGPointMake(CGRectGetMidX(self.frame), 120)
        bsLabel.position = CGPointMake(CGRectGetMidX(self.frame), 95)
        xpLabel.path = CGPathCreateWithRect(CGRect(x: 0, y: 0, width: CGFloat(GameViewController.getLevelXPFloat()) * size.width, height: 15), nil)
        txpLabel.position = CGPointMake(size.width / 2, 0)
        if actualPane == 1 {
            soloButton.position = CGPointMake(cancelled ? -soloButton.size.width : CGRectGetMidX(self.frame), getPositionYForButton(0, text: false))
            multiButton.position = CGPointMake(cancelled ? -multiButton.size.width : CGRectGetMidX(self.frame), getPositionYForButton(1, text: false))
            timedButton.position = CGPointMake(cancelled ? -timedButton.size.width : CGRectGetMidX(self.frame), getPositionYForButton(2, text: false))
            prefsButton.position = CGPointMake(cancelled ? -prefsButton.size.width : self.frame.width / 4, 170)
            bbstoreButton.position = CGPointMake(cancelled ? -bbstoreButton.size.width : self.frame.width / 4 * 3, 170)
            
            tsoloButton.position = CGPointMake(cancelled ? -soloButton.size.width : CGRectGetMidX(self.frame), getPositionYForButton(0, text: true))
            tmultiButton.position = CGPointMake(cancelled ? -multiButton.size.width : CGRectGetMidX(self.frame), getPositionYForButton(1, text: true))
            ttimedButton.position = CGPointMake(cancelled ? -timedButton.size.width : CGRectGetMidX(self.frame), getPositionYForButton(2, text: true))
            tprefsButton.position = CGPointMake(cancelled ? -prefsButton.size.width : self.frame.width / 4, 160)
            tbbstoreButton.position = CGPointMake(cancelled ? -bbstoreButton.size.width : self.frame.width / 4 * 3, 160)
        } else if actualPane == 2 {
            smallButton.position = CGPointMake(self.frame.size.width + smallButton.size.width, getPositionYForButton(0, text: false))
            mediumButton.position = CGPointMake(self.frame.size.width + mediumButton.size.width, getPositionYForButton(1, text: false))
            bigButton.position = CGPointMake(self.frame.size.width + bigButton.size.width, getPositionYForButton(2, text: false))
            adaptButton.position = CGPointMake(self.frame.size.width + adaptButton.size.width, getPositionYForButton(3, text: false))
            
            tsmallButton.position = CGPointMake(self.frame.size.width + smallButton.size.width, getPositionYForButton(0, text: true))
            tmediumButton.position = CGPointMake(self.frame.size.width + mediumButton.size.width, getPositionYForButton(1, text: true))
            tbigButton.position = CGPointMake(self.frame.size.width + bigButton.size.width, getPositionYForButton(2, text: true))
            tadaptButton.position = CGPointMake(self.frame.size.width + adaptButton.size.width, getPositionYForButton(3, text: true))
        } else {
            return false
        }
        return true
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
        tsmallButton.fontColor = SKColor.blackColor()
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
        tmediumButton.fontColor = SKColor.blackColor()
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
        tbigButton.fontColor = SKColor.blackColor()
        tbigButton.zPosition = 2
        self.addChild(tbigButton)
        
        adaptButton = SKSpriteNode(texture: buttonTexture)
        adaptButton.zPosition = 1
        self.addChild(adaptButton)
        tadaptButton = SKLabelNode()
        tadaptButton.text = String(format: NSLocalizedString("gamesize.adaptive", comment: "Adaptive"), Int((self.frame.size.width - 35) / 70), Int(self.frame.size.height / 70))
        tadaptButton.fontSize = 35
        tadaptButton.fontName = BUTTON_FONT
        tadaptButton.fontColor = SKColor.blackColor()
        tadaptButton.zPosition = 2
        self.addChild(tadaptButton)
        
        actualPane = 2
        adjustPosition(false)
    }
    
    func grey(sprite:SKSpriteNode) {
        sprite.color = SKColor.grayColor()
        sprite.colorBlendFactor = 0.5
    }
    
    func greyIfNotFill(sprite:SKSpriteNode, size:Int) {
        if Int(self.frame.size.width / 70) < size || Int((self.frame.size.height - 20) / 70) < size {
            grey(sprite)
        }
    }
    
    func getPositionYForButton(indexFromTop:Int, text:Bool) -> CGFloat {
        var position:CGFloat = 0
        let height = buttonTexture.size().height
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        /*
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)
        }*/
        if touches.count == 1 {
            touchesBegan = touches.first?.locationInNode(self)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touches.count == 1 {
            let point:CGPoint = (touches.first?.locationInNode(self))!
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
            } else if onNode(smallButton, point: point) {
                if smallButton.colorBlendFactor != 0.5 {
                    newGame(gametype, width: 5, height: 5)
                } else {
                    showAlert()
                }
            } else if onNode(mediumButton, point: point) {
                if smallButton.colorBlendFactor != 0.5 {
                    newGame(gametype, width: 7, height: 7)
                } else {
                    showAlert()
                }
            } else if onNode(bigButton, point: point) {
                if smallButton.colorBlendFactor != 0.5 {
                    newGame(gametype, width: 10, height: 10)
                } else {
                    showAlert()
                }
            } else if onNode(adaptButton, point: point) {
                newGame(gametype, width: UInt(self.frame.size.width / 70), height: UInt((self.frame.size.height - 20) / 70))
            } else if onNode(prefsButton, point: point) {
                if littleScreen() {
                    self.view?.presentScene(IPhoneSettingScene(previous: self), transition: SKTransition.doorsOpenHorizontalWithDuration(NSTimeInterval(1)))
                } else {
                    self.view?.presentScene(SettingScene(previous: self), transition: SKTransition.doorsOpenHorizontalWithDuration(NSTimeInterval(1)))
                }
            } else if onNode(bbstoreButton, point: point) {
                self.view?.presentScene(BBStoreScene(start: self), transition: SKTransition.doorsCloseVerticalWithDuration(NSTimeInterval(1)))
            }
        }
    }
    
    func littleScreen() -> Bool {
        return self.frame.height < 500
    }
    
    func showDialog(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.view!.window!.rootViewController!.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showAlert() {
        showDialog("Erreur", message: "Cette résolution ne tient pas sur votre écran")
    }
    
    func newGame(gametype:Int8, width:UInt, height:UInt) {
        self.view?.presentScene(GameScene(view: self.view!, gametype: gametype, width: width, height: height), transition: SKTransition.flipVerticalWithDuration(NSTimeInterval(1)));
    }
    
    func cancelScreen() {
        if actualPane == 2 {
            transitionSecondToFirst()
        } else if actualPane == 1 && lastGameInfo != nil {
            showDialog(NSLocalizedString("gameinfo.title", comment: "Last game information"), message: lastGameInfo!)
        }
    }
    
    func transitionFirstToSecond() {
        actualPane = -1
        transitionQuit(soloButton, relativeTo: soloButton)
        transitionQuit(multiButton, relativeTo: multiButton)
        transitionQuit(timedButton, relativeTo: timedButton)
        transitionQuit(prefsButton, relativeTo: prefsButton)
        transitionQuit(bbstoreButton, relativeTo: bbstoreButton)
        transitionQuit(tsoloButton, relativeTo: soloButton)
        transitionQuit(tmultiButton, relativeTo: multiButton)
        transitionQuit(ttimedButton, relativeTo: timedButton)
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
        self.runAction(SKAction.sequence([SKAction.waitForDuration(NSTimeInterval(0.5)), SKAction.runBlock({
            self.actualPane = 2;
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
        transitionJoinAt(prefsButton, at: CGPointMake(self.frame.width / 4, 170))
        transitionJoinAt(bbstoreButton, at: CGPointMake(self.frame.width / 4 * 3, 170))
        transitionJoinCenter(tsoloButton)
        transitionJoinCenter(tmultiButton)
        transitionJoinCenter(ttimedButton)
        transitionJoinAt(tprefsButton, at: CGPointMake(self.frame.width / 4, 160))
        transitionJoinAt(tbbstoreButton, at: CGPointMake(self.frame.width / 4 * 3, 160))
        self.runAction(SKAction.sequence([SKAction.waitForDuration(NSTimeInterval(0.5)), SKAction.runBlock({
            self.actualPane = 1;
        })]))
    }
    
    func transitionQuit(node:SKNode, relativeTo:SKNode) {
        let actionArray:[SKAction] = [SKAction] (arrayLiteral: SKAction.moveTo(CGPointMake(-relativeTo.frame.width/2, node.position.y), duration: NSTimeInterval(0.5)),SKAction.removeFromParent())
        node.runAction(SKAction.sequence(actionArray))
    }
    
    func transitionJoinCenter(node:SKNode) {
        node.runAction(SKAction.moveTo(CGPointMake(self.frame.width/2, node.position.y), duration: NSTimeInterval(0.5)))
    }
    
    func transitionJoinAt(node:SKNode, at:CGPoint) {
        node.runAction(SKAction.moveTo(at, duration: NSTimeInterval(0.5)))
    }
    
    func transitionQuitRight(node:SKNode, relativeTo:SKNode) {
        let actionArray:[SKAction] = [SKAction] (arrayLiteral: SKAction.moveTo(CGPointMake(self.frame.width + relativeTo.frame.width/2, node.position.y), duration: NSTimeInterval(0.5)),SKAction.removeFromParent())
        node.runAction(SKAction.sequence(actionArray))
    }
    
    func onNode(node:SKSpriteNode, point:CGPoint) -> Bool {
        return node.frame.contains(point)
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
