//
//  Button.swift
//  Button
//
//  Created by Emil Pedersen on 20/07/2021.
//  Copyright © 2021 Snowy_1803. All rights reserved.
//

import SpriteKit

class Button: SKSpriteNode {
    static let fontName = "ChalkboardSE-Light"
    static let textures: [Size: SKTexture] = [
        .normal: SKTexture(imageNamed: "buttonbg"),
        .mini: SKTexture(imageNamed: "buttonminibg"),
    ]
    
    let label: SKLabelNode
    
    init(size: Size, text: String) {
        let texture = Button.textures[size]!
        label = SKLabelNode(text: text)
        super.init(texture: texture, color: .clear, size: texture.size())
        self.zPosition = 1
        label.fontSize = size.fontSize
        label.fontName = Button.fontName
        label.fontColor = SKColor.black
        label.zPosition = 2
        label.position = CGPoint(x: 0, y: size.labelOffset)
        addChild(label)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum Size {
        case normal
        case mini
        
        var fontSize: CGFloat {
            switch self {
            case .normal:
                return 35
            case .mini:
                return 20
            }
        }
        
        var labelOffset: CGFloat {
            switch self {
            case .normal:
                return -15
            case .mini:
                return -10
            }
        }
    }
}
