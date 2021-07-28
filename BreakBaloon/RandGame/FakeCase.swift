//
//  FakeCase.swift
//  BreakBaloon
//
//  Created by Emil on 11/08/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation

class FakeCase: Case {
    override init(game: AbstractGameScene, index: Int) {
        super.init(game: game, index: index)
        texture = game.theme.getBaloonTexture(status: status, type: type, fake: true)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func breakBaloon(_ winner: Bool) {
        super.breakBaloon(winner)
        game.points -= 2
    }
}
