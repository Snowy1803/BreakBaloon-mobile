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
    let BUTTON_FONT = "ChalkboardSE-Light"
    let ANIMATION_REQUIREMENT = 2
    let HINTARROW_REQUIREMENT = 10
    let BEE_REQUIREMENT = 15
    let sortArray = ["animation": NSLocalizedString("extension.animation", comment: "Animation enabled?"), "hintArrow": NSLocalizedString("extension.hintarrow", comment: "HintArrow enabled?"), "bee": NSLocalizedString("extension.bee", comment: "Bee enabled?")]
    let previous: SKScene
    
    var ok = SKSpriteNode()
    let tok = SKLabelNode()
    
    var animation, hintarrow, bee: CheckBox
    
    init(_ previous: SKScene) {
        self.previous = previous
        self.animation = CheckBox(checked: NSUserDefaults.standardUserDefaults().boolForKey("extension.animation.enabled"), label: sortArray["animation"])
        self.hintarrow = CheckBox(checked: NSUserDefaults.standardUserDefaults().boolForKey("extension.hintarrow.enabled"), label: sortArray["hintArrow"])
        self.bee = CheckBox(checked: NSUserDefaults.standardUserDefaults().boolForKey("extension.bee.enabled"), label: sortArray["bee"])
        super.init(size: previous.size)
        backgroundColor = SKColor.brownColor()
        
        ok = SKSpriteNode(imageNamed: "buttonminibg")
        ok.position = CGPointMake(self.frame.width/2, 50)
        ok.zPosition = 1
        addChild(ok)
        tok.text = NSLocalizedString("ok", comment: "Ok")
        tok.fontName = BUTTON_FONT
        tok.fontColor = SKColor.blackColor()
        tok.fontSize = 20
        tok.position = CGPointMake(self.frame.width/2, 40)
        tok.zPosition = 2
        addChild(tok)
        let array = [String](sortArray.values)
        self.animation.enable(GameViewController.getLevel() >= ANIMATION_REQUIREMENT)
        animation.position = CGPointMake(32, self.frame.height - sort(sortArray["animation"]!, in: array))
        addChild(animation)
        self.hintarrow.enable(GameViewController.getLevel() >= HINTARROW_REQUIREMENT)
        hintarrow.position = CGPointMake(32, self.frame.height - sort(sortArray["hintArrow"]!, in: array))
        addChild(hintarrow)
        self.bee.enable(GameViewController.getLevel() >= BEE_REQUIREMENT)
        bee.position = CGPointMake(32, self.frame.height - sort(sortArray["bee"]!, in: array))
        addChild(bee)
    }
    
    func initialize() {
        self.animation.setTextureIfDisabled(view?.textureFromNode(getTexture(ANIMATION_REQUIREMENT)))
        self.hintarrow.setTextureIfDisabled(view?.textureFromNode(getTexture(HINTARROW_REQUIREMENT)))
        self.bee.setTextureIfDisabled(view?.textureFromNode(getTexture(BEE_REQUIREMENT)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touches.count == 1 {
            let point = touches.first!.locationInNode(self)
            if ok.frame.contains(point) {
                NSUserDefaults.standardUserDefaults().setBool(animation.checked, forKey: "extension.animation.enabled")
                NSUserDefaults.standardUserDefaults().setBool(hintarrow.checked, forKey: "extension.hintarrow.enabled")
                NSUserDefaults.standardUserDefaults().setBool(bee.checked, forKey: "extension.bee.enabled")
                view?.presentScene(previous, transition: SKTransition.pushWithDirection(.Right, duration: NSTimeInterval(1)))
            } else if animation.frame.contains(point) {
                animation.reverseCheck()
            } else if hintarrow.frame.contains(point) {
                hintarrow.reverseCheck()
            } else if bee.frame.contains(point) {
                bee.reverseCheck()
            }
        }
    }
    
    func sort(search: String, in array: [String]) -> CGFloat {
        return CGFloat(32 + array.sort().indexOf(search)! * 32)
    }
    
    func getTexture(requirement: Int) -> SKNode {
        let level = SKSpriteNode(imageNamed: "level")
        level.zPosition = 1
        level.setScale(1.5)
        let tlevel = SKLabelNode(text: "\(requirement)")
        tlevel.position = CGPointMake(0, requirement > 9 ? -8 : -12)
        tlevel.fontName = "AppleSDGothicNeo-Bold"
        tlevel.fontSize = requirement > 9 ? 16 : 24
        tlevel.fontColor = SKColor.whiteColor()
        tlevel.zPosition = 2
        level.addChild(tlevel)
        return level
    }
}