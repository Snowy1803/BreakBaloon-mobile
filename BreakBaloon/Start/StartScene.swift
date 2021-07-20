//
//  GameScene.swift
//  BreakBaloon
//
//  Created by Emil on 19/06/2016.
//  Copyright (c) 2016 Snowy_1803. All rights reserved.
//

import GameKit
import SpriteKit

class StartScene: SKScene {
    
    var bbLabel = SKLabelNode()
    var cLabel = SKLabelNode()
    var hsLabel = SKLabelNode()
    var bsLabel = SKLabelNode()
    
    var soloButton: Button!
    var multiButton: Button!
    var timedButton: Button!
    var randButton: Button!
    var smallButton: Button!
    var mediumButton: Button!
    var bigButton: Button!
    var adaptButton: Button!
    var prefsButton: Button!
    var bbstoreButton: Button!
    
    var xpLabel = SKShapeNode()
    var txpLabel = SKLabelNode()
    var levelProgressionShown: CGFloat = 0
    
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
        hsLabel.text = String(format: NSLocalizedString("highscore.score", comment: "Highscore"), PlayerProgress.current.soloHighscore)
        hsLabel.fontSize = 25
        hsLabel.fontName = "ChalkboardSE-Regular"
        hsLabel.fontColor = SKColor.orange
        addChild(hsLabel)
        bsLabel.text = String(format: NSLocalizedString("highscore.time", comment: "Best timed score"), PlayerProgress.current.timedHighscore)
        bsLabel.fontSize = 25
        bsLabel.fontName = "ChalkboardSE-Regular"
        bsLabel.fontColor = SKColor.orange
        addChild(bsLabel)
        levelProgressionShown = growXPFrom > -1 ? growXPFrom : CGFloat(PlayerProgress.current.levelProgression)
        print("init StartScene: XP: \(levelProgressionShown)")
        xpLabel = SKShapeNode(rect: CGRect(x: 0, y: 0, width: levelProgressionShown * size.width, height: 15))
        xpLabel.fillColor = SKColor(red: 0, green: 0.5, blue: 1, alpha: 1)
        xpLabel.strokeColor = SKColor.clear
        xpLabel.zPosition = 2
        addChild(xpLabel)
        if growXPFrom > -1 {
            growXP()
        }
        txpLabel = SKLabelNode(text: String(format: NSLocalizedString("level.label", comment: "Level x"), PlayerProgress.current.currentLevel))
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
        if #available(iOS 14.0, *) {
            GKAccessPoint.shared.isActive = true
        }
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        if #available(iOS 14.0, *) {
            GKAccessPoint.shared.isActive = false
        }
    }
    
    func growXP() {
        let growXPFrom = levelProgressionShown
        print("GrowXP: \(growXPFrom) -> \(PlayerProgress.current.levelProgression)")
        xpLabel.run(SKAction.sequence([SKAction.wait(forDuration: 0.1), SKAction.scaleX(to: CGFloat(PlayerProgress.current.levelProgression) / growXPFrom, duration: 1.0)])) { [self] in
            xpLabel.path = CGPath(rect: CGRect(x: 0, y: view?.safeAreaInsets.bottom ?? 0, width: CGFloat(PlayerProgress.current.levelProgression) * size.width, height: 15), transform: nil)
            xpLabel.xScale = 1
            levelProgressionShown = PlayerProgress.current.levelProgression
            txpLabel.text = String(format: NSLocalizedString("level.label", comment: "Level x"), PlayerProgress.current.currentLevel)
        }
    }
    
    // MARK: - Pane initializers
    
    func initGameTypePane(_ cancelled: Bool) {
        soloButton = Button(size: .normal, text: NSLocalizedString("gametype.singleplayer", comment: "Singleplayer"))
        addChild(soloButton)
        
        multiButton = Button(size: .normal, text: NSLocalizedString("gametype.computer", comment: "Versus computer"))
        addChild(multiButton)
        
        timedButton = Button(size: .normal, text: NSLocalizedString("gametype.timed", comment: "Timed game"))
        addChild(timedButton)
        
        randButton = Button(size: .normal, text: NSLocalizedString("gametype.rand", comment: "Game with random baloons spawning"))
        if PlayerProgress.current.currentLevel < RandGameScene.requirement {
            grey(randButton)
            let level = SKSpriteNode(imageNamed: "level")
            level.position = CGPoint(x: min(randButton.frame.width / 2, frame.width / 2) - 30, y: randButton.frame.midY)
            level.zPosition = 1
            level.setScale(1.5)
            randButton.addChild(level)
            let tlevel = SKLabelNode(text: "\(RandGameScene.requirement)")
            tlevel.position = CGPoint(x: min(randButton.frame.width / 2, frame.width / 2) - 30, y: randButton.frame.midY - 12)
            tlevel.fontName = "AppleSDGothicNeo-Bold"
            tlevel.fontSize = 24
            tlevel.fontColor = SKColor.white
            tlevel.zPosition = 2
            randButton.addChild(tlevel)
        }
        addChild(randButton)
        
        prefsButton = Button(size: .mini, text: NSLocalizedString("settings.title", comment: "Settings"))
        addChild(prefsButton)
        
        bbstoreButton = Button(size: .mini, text: NSLocalizedString("bbstore.button", comment: "BBStore"))
        addChild(bbstoreButton)

        currentPane = .selectGameType
        adjustPosition(cancelled)
    }
    
    func initSizeSelectionPane() {
        smallButton = Button(size: .normal, text: NSLocalizedString("gamesize.small", comment: "Small"))
        greyIfNotFill(smallButton, size: 5)
        addChild(smallButton)
        
        mediumButton = Button(size: .normal, text: NSLocalizedString("gamesize.medium", comment: "Normal"))
        greyIfNotFill(mediumButton, size: 7)
        addChild(mediumButton)
        
        bigButton = Button(size: .normal, text: NSLocalizedString("gamesize.large", comment: "Large"))
        greyIfNotFill(bigButton, size: 10)
        addChild(bigButton)
        
        let safeSize = frame.inset(by: view!.safeAreaInsets).size
        adaptButton = Button(size: .normal, text: String(format: NSLocalizedString("gamesize.adaptive", comment: "Adaptive"), Int(safeSize.width / 75), Int((safeSize.height - 35) / 75)))
        addChild(adaptButton)
        
        currentPane = .selectSize
        adjustPosition(false)
    }
    
    func initLevelSelectionPane() {
        let width = Int(frame.size.width / 75)
        for i in 0..<RandGameLevel.levels.count {
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
        xpLabel.path = CGPath(rect: CGRect(x: 0, y: bottomSA, width: CGFloat(levelProgressionShown) * size.width, height: 15), transform: nil)
        txpLabel.position = CGPoint(x: size.width / 2, y: 0 + bottomSA)
        switch currentPane {
        case .selectGameType:
            let bottomPadding = bottomSA - lowerButtonsOffset
            let translation = cancelled ? frame.width : 0
            soloButton.position = CGPoint(x: frame.midX - translation, y: getPositionYForButton(0))
            multiButton.position = CGPoint(x: frame.midX - translation, y: getPositionYForButton(1))
            timedButton.position = CGPoint(x: frame.midX - translation, y: getPositionYForButton(2))
            randButton.position = CGPoint(x: frame.midX - translation, y: getPositionYForButton(3))
            prefsButton.position = CGPoint(x: frame.width / 4 - translation, y: 170 + bottomPadding)
            bbstoreButton.position = CGPoint(x: frame.width / 4 * 3 - translation, y: 170 + bottomPadding)
        case .selectSize:
            let translation = sizeChange ? 0 : frame.size.width
            smallButton.position = CGPoint(x: frame.midX + translation, y: getPositionYForButton(0))
            mediumButton.position = CGPoint(x: frame.midX + translation, y: getPositionYForButton(1))
            bigButton.position = CGPoint(x: frame.midX + translation, y: getPositionYForButton(2))
            adaptButton.position = CGPoint(x: frame.midX + translation, y: getPositionYForButton(3))
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
    
    var heightIsShort: Bool {
        frame.height < 575
    }
    
    var lowerButtonsOffset: CGFloat {
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
    
    func getPositionYForButton(_ indexFromTop: Int) -> CGFloat {
        var position: CGFloat = frame.size.height - (view?.safeAreaInsets.top ?? 0)
        let height = Button.textures[.normal]!.size().height
        if UIDevice.current.userInterfaceIdiom == .pad {
            position -= height * (2 + 1.5 * CGFloat(indexFromTop - 1))
        } else {
            let landscape = view?.frame.width ?? 0 > view?.frame.height ?? 0
            position -= height * CGFloat(indexFromTop) + (landscape ? 0 : 100)
        }
        return position - 30
    }
    
    // MARK: - Events
    
    override func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
        if touches.count == 1 {
            touchesBegan = touches.first?.location(in: self)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with _: UIEvent?) {
        guard touches.count == 1, currentPane != .inTransition else {
            return
        }
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
            gametype = .timed
            transitionGameTypeToSizeSelection()
        } else if onNode(randButton, point: point) {
            if PlayerProgress.current.currentLevel >= RandGameScene.requirement {
                transitionGameTypeToLevelSelection()
            }
        } else if onNode(smallButton, point: point) {
            if smallButton.colorBlendFactor != 0.5 {
                newGame(gametype, width: 5, height: 5)
            } else {
                showResolutionAlert()
            }
        } else if onNode(mediumButton, point: point) {
            if mediumButton.colorBlendFactor != 0.5 {
                newGame(gametype, width: 7, height: 7)
            } else {
                showResolutionAlert()
            }
        } else if onNode(bigButton, point: point) {
            if bigButton.colorBlendFactor != 0.5 {
                newGame(gametype, width: 10, height: 10)
            } else {
                showResolutionAlert()
            }
        } else if onNode(adaptButton, point: point) {
            let safeSize = frame.inset(by: view!.safeAreaInsets).size
            newGame(gametype, width: Int(safeSize.width / 75), height: Int((safeSize.height - 20) / 75))
        } else if onNode(prefsButton, point: point) {
            if heightIsShort {
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
    
    func onNode(_ node: SKNode?, point: CGPoint) -> Bool {
        if let node = node {
            return node.frame.contains(point) && node.parent != nil
        }
        return false
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
        transitionLeaveGameType()
        initSizeSelectionPane()
        currentPane = .inTransition
        for node in [smallButton, mediumButton, bigButton, adaptButton] as [Button] {
            transitionJoinCenter(node)
        }
        run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.run {
            self.currentPane = .selectSize
        }]))
    }
    
    func transitionGameTypeToLevelSelection() {
        transitionLeaveGameType()
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
        for node in [smallButton, mediumButton, bigButton, adaptButton] as [Button] {
            transitionQuitRight(node)
        }
        transitionEnterGameType()
    }
    
    func transitionLevelSelectionToGameType() {
        currentPane = .inTransition
        for child in children where child is RandGameLevelNode {
            transitionQuitRight(child)
        }
        transitionEnterGameType()
    }
    
    func transitionLeaveGameType() {
        if #available(iOS 14.0, *) {
            GKAccessPoint.shared.isActive = false
        }
        currentPane = .inTransition
        for node in [soloButton, multiButton, timedButton, randButton, prefsButton, bbstoreButton] as [Button] {
            transitionQuit(node)
        }
    }
    
    func transitionEnterGameType() {
        initGameTypePane(true)
        currentPane = .inTransition
        for node in [soloButton, multiButton, timedButton, randButton] as [Button] {
            transitionJoinCenter(node)
        }
        let bottomSA = view?.safeAreaInsets.bottom ?? 0
        let bottomPadding = bottomSA - lowerButtonsOffset
        transitionJoinAt(prefsButton, at: CGPoint(x: frame.width / 4, y: 170 + bottomPadding))
        transitionJoinAt(bbstoreButton, at: CGPoint(x: frame.width / 4 * 3, y: 170 + bottomPadding))
        run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.run {
            self.currentPane = .selectGameType
        }]))
        if #available(iOS 14.0, *) {
            GKAccessPoint.shared.isActive = true
        }
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
