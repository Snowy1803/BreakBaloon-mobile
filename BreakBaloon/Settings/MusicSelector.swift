//
//  MusicSelector.swift
//  BreakBaloon
//
//  Created by Emil on 26/06/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import MediaPlayer
import SpriteKit

class MusicSelector: Selector {
    init(gvc: GameViewController) {
        super.init(gvc: gvc, title: NSLocalizedString("settings.music", comment: "Music"), value: gvc.currentMusicInt)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didSetSelectorValue() {
        gvc.currentMusicInt = value
        UserDefaults.standard.set(gvc.currentMusicFileName, forKey: "currentMusic")
        super.didSetSelectorValue()
        gvc.reloadBackgroundMusic()
    }
    
    override var maxValue: Int {
        GameViewController.getMusicURLs().count - 1
    }
    
    override var text: String {
        let cmps = GameViewController.getMusicURLs()[value].absoluteString.components(separatedBy: "/")
        let text = cmps[cmps.count - 1].components(separatedBy: ".")[0].removingPercentEncoding!
        return text == "Race" ? NSLocalizedString("theme.default.name", comment: "Default theme name") : text
    }
}
