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
        animation.position = CGPointMake(32, self.frame.height - sort(sortArray["animation"]!, in: array))
        addChild(animation)
        hintarrow.position = CGPointMake(32, self.frame.height - sort(sortArray["hintArrow"]!, in: array))
        addChild(hintarrow)
        bee.position = CGPointMake(32, self.frame.height - sort(sortArray["bee"]!, in: array))
        addChild(bee)
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
}