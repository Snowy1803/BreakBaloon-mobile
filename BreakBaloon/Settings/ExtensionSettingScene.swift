//
//  ExtensionSettingScene.swift
//  BreakBaloon
//
//  Created by Emil on 06/08/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit

class ExtensionSettingScene: SKScene {
    let animationLevelRequirement = 2
    let hintarrowLevelRequirement = 10
    let beeLevelRequirement = 15
    let sortArray = ["animation": NSLocalizedString("extension.animation", comment: "Animation enabled?"), "hintArrow": NSLocalizedString("extension.hintarrow", comment: "HintArrow enabled?"), "bee": NSLocalizedString("extension.bee", comment: "Bee enabled?")]
    let previous: SKScene
    
    var ok = SKSpriteNode()
    let tok = SKLabelNode()
    
    var animation, hintarrow, bee: CheckBox
    
    init(_ previous: SKScene) {
        self.previous = previous
        animation = CheckBox(checked: UserDefaults.standard.bool(forKey: "extension.animation.enabled"), label: sortArray["animation"])
        hintarrow = CheckBox(checked: UserDefaults.standard.bool(forKey: "extension.hintarrow.enabled"), label: sortArray["hintArrow"])
        bee = CheckBox(checked: UserDefaults.standard.bool(forKey: "extension.bee.enabled"), label: sortArray["bee"])
        super.init(size: previous.size)
        backgroundColor = SKColor.brown
        let top = frame.height - (previous.view?.safeAreaInsets.top ?? 0)
        let bottom = previous.view?.safeAreaInsets.bottom ?? 0
        let left = previous.view?.safeAreaInsets.left ?? 0
        
        ok = SKSpriteNode(imageNamed: "buttonminibg")
        ok.position = CGPoint(x: frame.width / 2, y: 50 + bottom)
        ok.zPosition = 1
        addChild(ok)
        tok.text = NSLocalizedString("ok", comment: "Ok")
        tok.fontName = StartScene.buttonFont
        tok.fontColor = SKColor.black
        tok.fontSize = 20
        tok.position = CGPoint(x: frame.width / 2, y: 40 + bottom)
        tok.zPosition = 2
        addChild(tok)
        let array = [String](sortArray.values)
        animation.enable(GameViewController.getLevel() >= animationLevelRequirement)
        animation.position = CGPoint(x: 32 + left, y: top - sort(sortArray["animation"]!, in: array))
        addChild(animation)
        hintarrow.enable(GameViewController.getLevel() >= hintarrowLevelRequirement)
        hintarrow.position = CGPoint(x: 32 + left, y: top - sort(sortArray["hintArrow"]!, in: array))
        addChild(hintarrow)
        bee.enable(GameViewController.getLevel() >= beeLevelRequirement)
        bee.position = CGPoint(x: 32 + left, y: top - sort(sortArray["bee"]!, in: array))
        addChild(bee)
    }
    
    func initialize() {
        animation.setTextureIfDisabled(view?.texture(from: getTexture(animationLevelRequirement)))
        hintarrow.setTextureIfDisabled(view?.texture(from: getTexture(hintarrowLevelRequirement)))
        bee.setTextureIfDisabled(view?.texture(from: getTexture(beeLevelRequirement)))
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with _: UIEvent?) {
        if touches.count == 1 {
            let point = touches.first!.location(in: self)
            if ok.frame.contains(point) {
                UserDefaults.standard.set(animation.checked, forKey: "extension.animation.enabled")
                UserDefaults.standard.set(hintarrow.checked, forKey: "extension.hintarrow.enabled")
                UserDefaults.standard.set(bee.checked, forKey: "extension.bee.enabled")
                view!.gvc.wcSession?.transferUserInfo(["extension.animation.enabled": animation.checked])
                view!.presentScene(previous, transition: SKTransition.push(with: .right, duration: TimeInterval(1)))
            } else if animation.frame.contains(point) {
                animation.reverseCheck()
            } else if hintarrow.frame.contains(point) {
                hintarrow.reverseCheck()
            } else if bee.frame.contains(point) {
                bee.reverseCheck()
            }
        }
    }
    
    func sort(_ search: String, in array: [String]) -> CGFloat {
        return CGFloat(32 + array.sorted().firstIndex(of: search)! * 32)
    }
    
    func getTexture(_ requirement: Int) -> SKNode {
        let level = SKSpriteNode(imageNamed: "level")
        level.zPosition = 1
        level.setScale(1.5)
        let tlevel = SKLabelNode(text: "\(requirement)")
        tlevel.position = CGPoint(x: 0, y: requirement > 9 ? -8 : -12)
        tlevel.fontName = "AppleSDGothicNeo-Bold"
        tlevel.fontSize = requirement > 9 ? 16 : 24
        tlevel.fontColor = SKColor.white
        tlevel.zPosition = 2
        level.addChild(tlevel)
        return level
    }
}
