//
//  ThemeSelector.swift
//  BreakBaloon
//
//  Created by Emil on 27/06/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit

class ThemeSelector: Selector {
    init(gvc:GameViewController) {
        super.init(gvc: gvc, value: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateAfterValueChange() {
        NSUserDefaults.standardUserDefaults().setInteger(value, forKey: "musicIndex")
        super.updateAfterValueChange()
        gvc.reloadBackgroundMusic()
    }
    
    override func maxValue() -> Int {
        return 0
    }
    
    override func text() -> String {
        return String(format: NSLocalizedString("theme.selector.text", comment: "Theme format"), NSLocalizedString("theme.default.name", comment: "Default theme name"))
    }
}