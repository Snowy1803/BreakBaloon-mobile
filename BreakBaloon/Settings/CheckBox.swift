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
    var checked: Bool {
        didSet {
            texture = SKTexture(imageNamed: "checkbox\(checked ? "-check" : "")")
        }
    }

    var enabled = true {
        didSet {
            texture = SKTexture(imageNamed: "checkbox\(enabled ? (checked ? "-check" : "") : "-disabled")")
        }
    }

    let label: SKLabelNode
    
    init(checked: Bool = false, label: String? = nil) {
        self.checked = checked
        self.label = SKLabelNode(text: label)
        let texture = SKTexture(imageNamed: "checkbox\(checked ? "-check" : "")")
        super.init(texture: texture, color: SKColor.white, size: texture.size())
        
        self.label.fontSize = 16
        self.label.fontColor = SKColor.black
        self.label.fontName = "ChalkboardSE-Bold"
        self.label.position = CGPoint(x: self.label.frame.width / 2 + frame.width, y: -8)
        addChild(self.label)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didTap() {
        if enabled {
            checked.toggle()
        }
    }
    
    func setTextureIfDisabled(_ texture: SKTexture?) {
        if !enabled {
            self.texture = texture
        }
    }
}
