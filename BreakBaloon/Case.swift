//
//  Case.swift
//  BreakBaloon
//
//  Created by Emil on 20/06/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit

class Case:SKSpriteNode {
    let gvc:GameViewController
    let type:Int
    let index:Int
    var status:CaseStatus = .Closed
    var breaked:Bool {
        get {
            return status != .Closed
        }
    }
    
    init(gvc:GameViewController, index:Int) {
        type = Int(arc4random_uniform(6))
        self.index = index
        self.gvc = gvc
        let texture = gvc.currentTheme.getBaloonTexture(status: status, type: type)
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func breakBaloon(winner:Bool) {
        status = winner ? .WinnerOpened : .Opened
        texture = gvc.currentTheme.getBaloonTexture(self)
    }
    
    enum CaseStatus: Int {
        case Closed
        case Opened
        case WinnerOpened
    }
}