//
//  GameScene.swift
//  BreakBaloon
//
//  Created by Emil on 19/06/2016.
//  Copyright (c) 2016 Snowy_1803. All rights reserved.
//

import SpriteKit

class StartScene: SKScene {
    static let buttonFont = "ChalkboardSE-Light"
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
    
    var currentPane = Pane.selectGameType
    var touchesBegan: CGPoint?
    var gametype = GameType.undefined
    var lastGameInfo: String?
    
    override convenience init(size: CGSize) {
        self.init(size: size, growXPFrom: -1)
    }
    
    init(size: CGSize, growXPFrom: CGFloat) {
        super.init(size: size)
        backgroundColor = SKColor.brown
        isPaused = true
        initGameTypePane(false)
        
        if UIDevice.current.userInterfaceIdiom != .phone {
            bbLabel.text = "BreakBaloon"
            bbLabel.fontSize = 45
            bbLabel.fontName = "Chalkduster"
            bbLabel.fontColor = SKColor.white
            addChild(bbLabel)
        }
        cLabel.text = "© Snowy_1803"
        cLabel.fontSize = 10
        cLabel.fontName = "ChalkboardSE-Regular"
        cLabel.fontColor = SKColor.white
        addChild(cLabel)
        hsLabel.text = String(format: NSLocalizedString("highscore.score", comment: "Highscore"), UserDefaults.standard.integer(forKey: "highscore"))
        hsLabel.fontSize = 25
        hsLabel.fontName = "ChalkboardSE-Regular"
        hsLabel.fontColor = SKColor.orange
        addChild(hsLabel)
        bsLabel.text = String(format: NSLocalizedString("highscore.time", comment: "Best timed score"), UserDefaults.standard.integer(forKey: "bestTimedScore"))
        bsLabel.fontSize = 25
        bsLabel.fontName = "ChalkboardSE-Regular"
        bsLabel.fontColor = SKColor.orange
        addChild(bsLabel)
        print(growXPFrom > -1 ? growXPFrom : CGFloat(GameViewController.getLevelXPFloat()))
        xpLabel = SKShapeNode(rect: CGRect(x: 0, y: 0, width: (growXPFrom > -1 ? growXPFrom : CGFloat(GameViewController.getLevelXPFloat())) * size.width, height: 15))
        xpLabel.fillColor = SKColor(red: 0, green: 0.5, blue: 1, alpha: 1)
        xpLabel.strokeColor = SKColor.clear
        xpLabel.zPosition = 2
        addChild(xpLabel)
        if growXPFrom > -1 {
            print("GrowXP: \(growXPFrom) -> \(GameViewController.getLevelXPFloat())")
            xpLabel.run(SKAction.sequence([SKAction.wait(forDuration: 0.1), SKAction.scaleX(to: CGFloat(GameViewController.getLevelXPFloat()) / growXPFrom, duration: 1.0)])) { [self] in
                xpLabel.path = CGPath(rect: CGRect(x: 0, y: view?.safeAreaInsets.bottom ?? 0, width: CGFloat(GameViewController.getLevelXPFloat()) * size.width, height: 15), transform: nil)
            }
        }
        txpLabel = SKLabelNode(text: String(format: NSLocalizedString("level.label", comment: "Level x"), GameViewController.getLevel()))
        txpLabel.fontSize = 13
        txpLabel.fontName = "AppleSDGothicNeo-Bold"
        txpLabel.fontColor = SKColor.white
        txpLabel.zPosition = 3
        addChild(txpLabel)
        adjustPosition(false)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        DispatchQueue.main.async { // safeAreaInsets aren't initialized yet here. wait 1 tick
            self.adjustPosition(false)
        }
    }
    
    // MARK: - Pane initializers
    
    func initGameTypePane(_ cancelled: Bool) {
        soloButton = SKSpriteNode(texture: buttonTexture)
        soloButton.zPosition = 1
        addChild(soloButton)
        tsoloButton.text = NSLocalizedString("gametype.singleplayer", comment: "Singleplayer")
        tsoloButton.fontSize = 35
        tsoloButton.fontName = StartScene.buttonFont
        tsoloButton.fontColor = SKColor.black
        tsoloButton.zPosition = 2
        addChild(tsoloButton)
        
        multiButton = SKSpriteNode(texture: buttonTexture)
        multiButton.zPosition = 1
        addChild(multiButton)
        tmultiButton.text = NSLocalizedString("gametype.computer", comment: "Versus computer")
        tmultiButton.fontSize = 35
        tmultiButton.fontName = StartScene.buttonFont
        tmultiButton.fontColor = SKColor.black
        tmultiButton.zPosition = 2
        addChild(tmultiButton)
        
        timedButton = SKSpriteNode(texture: buttonTexture)
        timedButton.zPosition = 1
        addChild(timedButton)
        ttimedButton.text = NSLocalizedString("gametype.timed", comment: "Timed game")
        ttimedButton.fontSize = 35
        ttimedButton.fontName = StartScene.buttonFont
        ttimedButton.fontColor = SKColor.black
        ttimedButton.zPosition = 2
        addChild(ttimedButton)
        
        randButton = SKSpriteNode(texture: buttonTexture)
        randButton.zPosition = 1
        if GameViewController.getLevel() < RandGameScene.REQUIREMENT {
            grey(randButton)
            let level = SKSpriteNode(imageNamed: "level")
            level.position = CGPoint(x: min(randButton.frame.width / 2, frame.width / 2) - 30, y: randButton.frame.midY)
            print(level.position)
            level.zPosition = 1
            level.setScale(1.5)
            randButton.addChild(level)
            let tlevel = SKLabelNode(text: "\(RandGameScene.REQUIREMENT)")
            tlevel.position = CGPoint(x: min(randButton.frame.width / 2, frame.width / 2) - 30, y: randButton.frame.midY - 12)
            tlevel.fontName = "AppleSDGothicNeo-Bold"
            tlevel.fontSize = 24
            tlevel.fontColor = SKColor.white
            tlevel.zPosition = 2
            randButton.addChild(tlevel)
        }
        addChild(randButton)
        trandButton.text = NSLocalizedString("gametype.rand", comment: "Game with random baloons spawning")
        trandButton.fontSize = 35
        trandButton.fontName = StartScene.buttonFont
        trandButton.fontColor = SKColor.black
        trandButton.zPosition = 2
        addChild(trandButton)
        
        prefsButton = SKSpriteNode(texture: minibuttonTexture)
        prefsButton.zPosition = 1
        addChild(prefsButton)
        tprefsButton.text = NSLocalizedString("settings.title", comment: "Settings")
        tprefsButton.fontSize = 20
        tprefsButton.fontName = StartScene.buttonFont
        tprefsButton.fontColor = SKColor.black
        tprefsButton.zPosition = 2
        addChild(tprefsButton)
        
        bbstoreButton = SKSpriteNode(texture: minibuttonTexture)
        bbstoreButton.zPosition = 1
        addChild(bbstoreButton)
        tbbstoreButton.text = NSLocalizedString("bbstore.button", comment: "BBStore")
        tbbstoreButton.fontSize = 20
        tbbstoreButton.fontName = StartScene.buttonFont
        tbbstoreButton.fontColor = SKColor.black
        tbbstoreButton.zPosition = 2
        addChild(tbbstoreButton)

        currentPane = .selectGameType
        adjustPosition(cancelled)
    }
    
    func initSizeSelectionPane() {
        smallButton = SKSpriteNode(texture: buttonTexture)
        smallButton.zPosition = 1
        greyIfNotFill(smallButton, size: 5)
        addChild(smallButton)
        tsmallButton = SKLabelNode()
        tsmallButton.text = NSLocalizedString("gamesize.small", comment: "Small")
        tsmallButton.fontSize = 35
        tsmallButton.fontName = StartScene.buttonFont
        tsmallButton.fontColor = SKColor.black
        tsmallButton.zPosition = 2
        addChild(tsmallButton)
        
        mediumButton = SKSpriteNode(texture: buttonTexture)
        mediumButton.zPosition = 1
        greyIfNotFill(mediumButton, size: 7)
        addChild(mediumButton)
        tmediumButton = SKLabelNode()
        tmediumButton.text = NSLocalizedString("gamesize.medium", comment: "Normal")
        tmediumButton.fontSize = 35
        tmediumButton.fontName = StartScene.buttonFont
        tmediumButton.fontColor = SKColor.black
        tmediumButton.zPosition = 2
        addChild(tmediumButton)
        
        bigButton = SKSpriteNode(texture: buttonTexture)
        bigButton.zPosition = 1
        greyIfNotFill(bigButton, size: 10)
        addChild(bigButton)
        tbigButton = SKLabelNode()
        tbigButton.text = NSLocalizedString("gamesize.large", comment: "Large")
        tbigButton.fontSize = 35
        tbigButton.fontName = StartScene.buttonFont
        tbigButton.fontColor = SKColor.black
        tbigButton.zPosition = 2
        addChild(tbigButton)
        
        adaptButton = SKSpriteNode(texture: buttonTexture)
        adaptButton.zPosition = 1
        addChild(adaptButton)
        tadaptButton = SKLabelNode()
        let safeSize = frame.inset(by: view!.safeAreaInsets).size
        tadaptButton.text = String(format: NSLocalizedString("gamesize.adaptive", comment: "Adaptive"), Int(safeSize.width / 75), Int((safeSize.height - 35) / 75))
        tadaptButton.fontSize = 35
        tadaptButton.fontName = StartScene.buttonFont
        tadaptButton.fontColor = SKColor.black
        tadaptButton.zPosition = 2
        addChild(tadaptButton)
        
        currentPane = .selectSize
        adjustPosition(false)
    }
    
    func initLevelSelectionPane() {
        let width = Int(frame.size.width / 75)
        for i in 0 ..< RandGameLevel.levels.count {
            let node = RandGameLevel.levels[i].createNode()
            node.realPosition = CGPoint(x: CGFloat(i % width * 75 + 35), y: frame.size.height - CGFloat(i / width * 75 + 35) - (view?.safeAreaInsets.top ?? 0))
            addChild(node)
        }
        
        currentPane = .selectLevel
        adjustPosition(false)
    }
    
    // MARK: - Layout
    
    func adjustPosition(_ cancelled: Bool, sizeChange: Bool = false) {
        let bottomSA = view?.safeAreaInsets.bottom ?? 0
        if UIDevice.current.userInterfaceIdiom != .phone {
            bbLabel.position = CGPoint(x: frame.midX, y: 40 + bottomSA)
            hsLabel.position = CGPoint(x: frame.midX, y: 120 + bottomSA)
            bsLabel.position = CGPoint(x: frame.midX, y: 95 + bottomSA)
        } else {
            hsLabel.position = CGPoint(x: frame.midX, y: 70 + bottomSA)
            bsLabel.position = CGPoint(x: frame.midX, y: 45 + bottomSA)
        }
        cLabel.position = CGPoint(x: frame.midX, y: 20 + bottomSA)
        xpLabel.path = CGPath(rect: CGRect(x: 0, y: bottomSA, width: CGFloat(GameViewController.getLevelXPFloat()) * size.width, height: 15), transform: nil)
        txpLabel.position = CGPoint(x: size.width / 2, y: 0 + bottomSA)
        switch currentPane {
        case .selectGameType:
            let bottomPadding = bottomSA - lowerButtonMinus()
            let translation = cancelled ? frame.width : 0
            soloButton.position = CGPoint(x: frame.midX - translation, y: getPositionYForButton(0, text: false))
            multiButton.position = CGPoint(x: frame.midX - translation, y: getPositionYForButton(1, text: false))
            timedButton.position = CGPoint(x: frame.midX - translation, y: getPositionYForButton(2, text: false))
            randButton.position = CGPoint(x: frame.midX - translation, y: getPositionYForButton(3, text: false))
            prefsButton.position = CGPoint(x: frame.width / 4 - translation, y: 170 + bottomPadding)
            bbstoreButton.position = CGPoint(x: frame.width / 4 * 3 - translation, y: 170 + bottomPadding)
            
            tsoloButton.position = CGPoint(x: frame.midX - translation, y: getPositionYForButton(0, text: true))
            tmultiButton.position = CGPoint(x: frame.midX - translation, y: getPositionYForButton(1, text: true))
            ttimedButton.position = CGPoint(x: frame.midX - translation, y: getPositionYForButton(2, text: true))
            trandButton.position = CGPoint(x: frame.midX - translation, y: getPositionYForButton(3, text: true))
            tprefsButton.position = CGPoint(x: frame.width / 4 - translation, y: 160 + bottomPadding)
            tbbstoreButton.position = CGPoint(x: frame.width / 4 * 3 - translation, y: 160 + bottomPadding)
        case .selectSize:
            let translation = sizeChange ? 0 : frame.size.width
            smallButton.position = CGPoint(x: frame.midX + translation, y: getPositionYForButton(0, text: false))
            mediumButton.position = CGPoint(x: frame.midX + translation, y: getPositionYForButton(1, text: false))
            bigButton.position = CGPoint(x: frame.midX + translation, y: getPositionYForButton(2, text: false))
            adaptButton.position = CGPoint(x: frame.midX + translation, y: getPositionYForButton(3, text: false))
            
            tsmallButton.position = CGPoint(x: frame.midX + translation, y: getPositionYForButton(0, text: true))
            tmediumButton.position = CGPoint(x: frame.midX + translation, y: getPositionYForButton(1, text: true))
            tbigButton.position = CGPoint(x: frame.midX + translation, y: getPositionYForButton(2, text: true))
            tadaptButton.position = CGPoint(x: frame.midX + translation, y: getPositionYForButton(3, text: true))
        case .selectLevel:
            if sizeChange {
                for child in children {
                    if let child = child as? RandGameLevelNode {
                        child.removeFromParent()
                    }
                }
                initLevelSelectionPane()
            }
            let translation = sizeChange ? 0 : frame.size.width
            for child in children {
                if let child = child as? RandGameLevelNode {
                    child.position = CGPoint(x: child.realPosition.x + translation, y: child.realPosition.y)
                }
            }
        case .inTransition:
            break
        }
    }
    
    // MARK: - Utils
    
    func littleScreen() -> Bool {
        frame.height < 575
    }
    
    func lowerButtonMinus() -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return 50
        }
        return 0
    }
    
    func grey(_ sprite: SKSpriteNode) {
        sprite.color = SKColor.gray
        sprite.colorBlendFactor = 0.5
    }
    
    func greyIfNotFill(_ sprite: SKSpriteNode, size: Int) {
        let safeSize = frame.inset(by: view!.safeAreaInsets).size
        if Int(safeSize.width / 75) < size || Int((safeSize.height - 20) / 75) < size {
            grey(sprite)
        }
    }
    
    func getPositionYForButton(_ indexFromTop: Int, text: Bool) -> CGFloat {
        var position: CGFloat = frame.size.height - (view?.safeAreaInsets.top ?? 0)
        let height = buttonTexture.size().height
        if UIDevice.current.userInterfaceIdiom == .pad {
            if indexFromTop == 0 {
                position -= height / 2
            } else if indexFromTop == 1 {
                position -= height * 2
            } else {
                position -= height * (2 + 1.5 * CGFloat(indexFromTop - 1))
            }
        } else {
            position -= height * CGFloat(indexFromTop)
        }
        return text ? position - 45 : position - 30
    }
    
    // MARK: - Events
    
    override func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
        if touches.count == 1 {
            touchesBegan = touches.first?.location(in: self)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with _: UIEvent?) {
        if touches.count == 1 {
            let point: CGPoint = (touches.first?.location(in: self))!
            if !(touchesBegan!.x <= point.x + 10 && touchesBegan!.x >= point.x - 10 && touchesBegan!.y <= point.y + 10 && touchesBegan!.y >= point.y - 10) {
                if touchesBegan!.x < point.x - 100 {
                    cancelScreen()
                }
            } else if onNode(soloButton, point: point) {
                gametype = .solo
                transitionGameTypeToSizeSelection()
            } else if onNode(multiButton, point: point) {
                gametype = .computer
                transitionGameTypeToSizeSelection()
            } else if onNode(timedButton, point: point) {
                gametype = .random
                transitionGameTypeToSizeSelection()
            } else if onNode(randButton, point: point) {
                if GameViewController.getLevel() >= RandGameScene.REQUIREMENT {
                    transitionGameTypeToLevelSelection()
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
                let safeSize = frame.inset(by: view!.safeAreaInsets).size
                newGame(gametype, width: Int(safeSize.width / 75), height: Int((safeSize.height - 20) / 75))
            } else if onNode(prefsButton, point: point) {
                if littleScreen() {
                    view?.presentScene(IPhoneSettingScene(previous: self), transition: SKTransition.doorsOpenHorizontal(withDuration: 1))
                } else {
                    view?.presentScene(SettingScene(previous: self), transition: SKTransition.doorsOpenHorizontal(withDuration: 1))
                }
            } else if onNode(bbstoreButton, point: point) {
                view?.presentScene(BBStoreScene(start: self), transition: SKTransition.doorsCloseVertical(withDuration: 1))
            } else if currentPane == .selectLevel {
                for child in children {
                    if let child = child as? RandGameLevelNode, onNode(child, point: point) {
                        child.click(view!)
                        break
                    }
                }
            }
        }
    }
    
    func onNode(_ node: SKNode, point: CGPoint) -> Bool {
        node.frame.contains(point)
    }
   
    override func update(_: TimeInterval) {
        /* Called before each frame is rendered */
        if isPaused {
            isPaused = false
        }
    }
    
    func showDialog(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        view!.window!.rootViewController!.present(alert, animated: true, completion: nil)
    }
    
    func showResolutionAlert() {
        showDialog(NSLocalizedString("error", comment: "error"), message: NSLocalizedString("gamesize.error", comment: "++ resolution"))
    }
    
    func showLevelAlert() {
        showDialog(NSLocalizedString("error", comment: "error"), message: NSLocalizedString("gametype.error", comment: "play to unlock"))
    }
    
    func newGame(_ gametype: GameType, width: Int, height: Int) {
        view?.presentScene(GameScene(view: view!, gametype: gametype, width: width, height: height), transition: SKTransition.flipVertical(withDuration: 1))
    }
    
    // MARK: - Transitions
    
    func cancelScreen() {
        switch currentPane {
        case .selectGameType:
            if let lastGameInfo = lastGameInfo {
                showDialog(NSLocalizedString("gameinfo.title", comment: "Last game information"), message: lastGameInfo)
            }
        case .selectSize:
            transitionSizeSelectionToGameType()
        case .selectLevel:
            transitionLevelSelectionToGameType()
        case .inTransition:
            break
        }
    }
    
    func transitionGameTypeToSizeSelection() {
        currentPane = .inTransition
        for node in [soloButton, multiButton, timedButton, randButton, prefsButton, bbstoreButton,
                     tsoloButton, tmultiButton, ttimedButton, trandButton, tprefsButton, tbbstoreButton] {
            transitionQuit(node)
        }
        initSizeSelectionPane()
        currentPane = .inTransition
        for node in [smallButton, mediumButton, bigButton, adaptButton, tsmallButton, tmediumButton, tbigButton, tadaptButton] {
            transitionJoinCenter(node)
        }
        run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.run {
            self.currentPane = .selectSize
        }]))
    }
    
    func transitionGameTypeToLevelSelection() {
        currentPane = .inTransition
        for node in [soloButton, multiButton, timedButton, randButton, prefsButton, bbstoreButton,
                     tsoloButton, tmultiButton, ttimedButton, trandButton, tprefsButton, tbbstoreButton] {
            transitionQuit(node)
        }
        initLevelSelectionPane()
        currentPane = .inTransition
        for child in children {
            if let child = child as? RandGameLevelNode {
                child.run(SKAction.move(to: child.realPosition, duration: 0.5))
            }
        }
        run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.run {
            self.currentPane = .selectLevel
        }]))
    }
    
    func transitionSizeSelectionToGameType() {
        currentPane = .inTransition
        for node in [smallButton, mediumButton, bigButton, adaptButton, tsmallButton, tmediumButton, tbigButton, tadaptButton] {
            transitionQuitRight(node)
        }
        initGameTypePane(true)
        currentPane = .inTransition
        for node in [soloButton, multiButton, timedButton, randButton, tsoloButton, tmultiButton, ttimedButton, trandButton] {
            transitionJoinCenter(node)
        }
        transitionJoinAt(prefsButton, at: CGPoint(x: frame.width / 4, y: 170))
        transitionJoinAt(bbstoreButton, at: CGPoint(x: frame.width / 4 * 3, y: 170))
        transitionJoinAt(tprefsButton, at: CGPoint(x: frame.width / 4, y: 160))
        transitionJoinAt(tbbstoreButton, at: CGPoint(x: frame.width / 4 * 3, y: 160))
        run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.run {
            self.currentPane = .selectGameType
        }]))
    }
    
    func transitionLevelSelectionToGameType() {
        currentPane = .inTransition
        for child in children where child is RandGameLevelNode {
            transitionQuitRight(child)
        }
        initGameTypePane(true)
        currentPane = .inTransition
        for node in [soloButton, multiButton, timedButton, randButton, tsoloButton, tmultiButton, ttimedButton, trandButton] {
            transitionJoinCenter(node)
        }
        transitionJoinAt(prefsButton, at: CGPoint(x: frame.width / 4, y: 170))
        transitionJoinAt(bbstoreButton, at: CGPoint(x: frame.width / 4 * 3, y: 170))
        transitionJoinAt(tprefsButton, at: CGPoint(x: frame.width / 4, y: 160))
        transitionJoinAt(tbbstoreButton, at: CGPoint(x: frame.width / 4 * 3, y: 160))
        run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.run {
            self.currentPane = .selectGameType
        }]))
    }
    
    func transitionQuit(_ node: SKNode) {
        node.run(SKAction.sequence([
            SKAction.move(to: CGPoint(x: node.position.x - frame.width, y: node.position.y), duration: 0.5),
            SKAction.removeFromParent(),
        ]))
    }
    
    func transitionJoinCenter(_ node: SKNode) {
        node.run(SKAction.move(to: CGPoint(x: frame.width / 2, y: node.position.y), duration: 0.5))
    }
    
    func transitionJoinAt(_ node: SKNode, at: CGPoint) {
        node.run(SKAction.move(to: at, duration: 0.5))
    }
    
    func transitionQuitRight(_ node: SKNode) {
        node.run(SKAction.sequence([
            SKAction.move(to: CGPoint(x: node.position.x + frame.width, y: node.position.y), duration: 0.5),
            SKAction.removeFromParent(),
        ]))
    }
    
    enum Pane {
        case inTransition
        case selectGameType
        case selectSize
        case selectLevel
    }
}
