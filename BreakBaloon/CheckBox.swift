//
//  CheckBox.swift
//  BreakBaloon
//
//  Created by Emil on 05/08/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit

class CheckBox: SKSpriteNode {
    private(set) var checked:Bool
    let label: SKLabelNode
    
    init(checked: Bool = false, label: String? = nil) {
        self.checked = checked
        self.label = SKLabelNode(text: label)
        let texture = SKTexture(imageNamed: "checkbox\(checked ? "-check" : "")")
        super.init(texture: texture, color: SKColor.whiteColor(), size: texture.size())
        
        self.label.fontSize = 16
        self.label.fontColor = SKColor.blackColor()
        self.label.fontName = "ChalkboardSE-Bold"
        self.label.position = CGPointMake(self.label.frame.width / 2 + self.frame.width, -8)
        addChild(self.label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func check(check: Bool) {
        self.checked = check
        texture = SKTexture(imageNamed: "checkbox\(check ? "-check" : "")")
    }
    
    func reverseCheck() {
        check(!checked)
    }
    
    func check() {
        check(true)
    }
    
    func uncheck() {
        check(false)
    }
}