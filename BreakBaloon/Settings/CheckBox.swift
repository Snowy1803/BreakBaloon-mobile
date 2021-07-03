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
    fileprivate(set) var checked:Bool
    fileprivate(set) var enabled = true
    let label: SKLabelNode
    
    init(checked: Bool = false, label: String? = nil) {
        self.checked = checked
        self.label = SKLabelNode(text: label)
        let texture = SKTexture(imageNamed: "checkbox\(checked ? "-check" : "")")
        super.init(texture: texture, color: SKColor.white, size: texture.size())
        
        self.label.fontSize = 16
        self.label.fontColor = SKColor.black
        self.label.fontName = "ChalkboardSE-Bold"
        self.label.position = CGPoint(x: self.label.frame.width / 2 + self.frame.width, y: -8)
        addChild(self.label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func check(_ check: Bool) {
        if enabled {
            self.checked = check
            texture = SKTexture(imageNamed: "checkbox\(check ? "-check" : "")")
        }
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
    
    func enable(_ enable: Bool) {
        enabled = enable
        texture = SKTexture(imageNamed: "checkbox\(enable ? checked ? "-check" : "" : "-disabled")")
    }
    
    func setTextureIfDisabled(_ texture: SKTexture?) {
        if !enabled {
            self.texture = texture
        }
    }
}
