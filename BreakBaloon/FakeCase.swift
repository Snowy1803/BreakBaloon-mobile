//
//  FakeCase.swift
//  BreakBaloon
//
//  Created by Emil on 11/08/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation

class FakeCase: Case {
    
    override init(gvc: GameViewController, index: Int) {
        super.init(gvc: gvc, index: index)
        texture = gvc.currentTheme.getBaloonTexture(status: status, type: type, fake: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func breakBaloon(winner: Bool) {
        super.breakBaloon(winner)
        gvc.currentGame?.points -= 2
    }
}