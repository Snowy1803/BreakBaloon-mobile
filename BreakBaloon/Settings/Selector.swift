//
//  Selector.swift
//  BreakBaloon
//
//  Created by Emil on 27/06/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit

class Selector:SKSpriteNode {
    fileprivate(set) var value:Int
    var tname:SKLabelNode
    var gvc:GameViewController
    
    init(gvc:GameViewController, value:Int) {
        let texture = SKTexture(imageNamed: "select")
        self.value = value
        tname = SKLabelNode()
        self.gvc = gvc
        super.init(texture: texture, color: SKColor.white, size: texture.size())
        self.setScale(2)
        tname.text = text()
        tname.position = CGPoint(x: 0, y: -5)
        tname.fontName = "ChalkboardSE-Light"
        tname.fontColor = SKColor.black
        tname.fontSize = 12
        tname.zPosition = 3
        addChild(tname)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func click(_ touch: UITouch) {
        let point = touch.location(in: self)
        if point.y > -10 && point.y < 10 {
            if point.x > -69 && point.x < -53 {
                value -= 1
                if value < 0 {
                    value = maxValue()
                }
            } else if point.x > 53 && point.x < 69 {
                value += 1
                if value > maxValue() {
                    value = 0
                }
            } else {
                return
            }
            updateAfterValueChange()
        }
    }
    
    func setSelectorValue(_ value:Int) {
        self.value = value
        updateAfterValueChange()
    }
    
    func reset() {
        gvc.currentMusicFileName = "Race.m4a"
        value = gvc.currentMusicInt
        updateAfterValueChange()
    }
    
    func updateAfterValueChange() {
        tname.text = text()
    }
    
    func maxValue() -> Int {
        return -1
    }
    
    func text() -> String {
        return "Not implemented"
    }
}
