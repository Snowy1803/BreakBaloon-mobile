//
//  Selector.swift
//  BreakBaloon
//
//  Created by Emil on 27/06/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit

class Selector: SKSpriteNode {
    var tname: SKLabelNode
    var gvc: GameViewController
    
    var value: Int {
        didSet {
            didSetSelectorValue()
        }
    }
    
    init(gvc: GameViewController, title: String, value: Int) {
        let texture = SKTexture(imageNamed: "select")
        self.value = value
        tname = SKLabelNode()
        self.gvc = gvc
        super.init(texture: texture, color: SKColor.white, size: texture.size())
        setScale(2)
        tname.text = text
        tname.position = CGPoint(x: 0, y: -5)
        tname.fontName = "ChalkboardSE-Light"
        tname.fontColor = SKColor.black
        tname.fontSize = 12
        tname.zPosition = 3
        addChild(tname)
        
        let ttitle = SKLabelNode()
        ttitle.text = title
        ttitle.position = CGPoint(x: -self.frame.width / 4, y: self.frame.height / 4 - 15)
        ttitle.fontName = "ChalkboardSE-Light"
        ttitle.fontColor = SKColor.black
        ttitle.fontSize = 8
        ttitle.zPosition = 3.5
        ttitle.horizontalAlignmentMode = .left
        addChild(ttitle)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func click(_ touch: UITouch) {
        let point = touch.location(in: self)
        if point.y > -10, point.y < 10 {
            var val = value
            if point.x > -69, point.x < -53 {
                val -= 1
                if val < 0 {
                    val = maxValue
                }
            } else if point.x > 53, point.x < 69 {
                val += 1
                if val > maxValue {
                    val = 0
                }
            } else {
                return
            }
            value = val
        }
    }
    
    func reset() {
        gvc.currentMusicFileName = "Race.m4a"
        value = gvc.currentMusicInt
    }
    
    func didSetSelectorValue() {
        tname.text = text
    }
    
    var maxValue: Int {
        0
    }
    
    var text: String {
        "Not implemented"
    }
}
