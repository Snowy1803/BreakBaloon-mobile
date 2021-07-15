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
    init(gvc: GameViewController) {
        super.init(gvc: gvc, title: NSLocalizedString("settings.theme", comment: "Theme"), value: gvc.currentThemeInt)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didSetSelectorValue() {
        gvc.currentThemeInt = value
        UserDefaults.standard.set(gvc.currentTheme.id, forKey: "currentTheme")
        super.didSetSelectorValue()
    }
    
    override var maxValue: Int {
        AbstractThemeUtils.themeList.count - 1
    }
    
    override var text: String {
        gvc.currentTheme.name
    }
}
