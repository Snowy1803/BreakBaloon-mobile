//
//  ThemeSelector.swift
//  BreakBaloon
//
//  Created by Emil on 27/06/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import UIKit

class ThemeSelector: Selector {
    init(gvc:GameViewController) {
        super.init(gvc: gvc, value: 0)
        setSelectorValue(gvc.currentThemeInt)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateAfterValueChange() {
        gvc.currentThemeInt = value
        NSUserDefaults.standardUserDefaults().setObject(gvc.currentTheme.themeID, forKey: "currentTheme")
        super.updateAfterValueChange()
    }
    
    override func maxValue() -> Int {
        return Theme.themeList.count - 1
    }
    
    override func text() -> String {
        return String(format: NSLocalizedString("theme.selector.text", comment: "Theme format"), gvc.currentTheme.name)
    }
}