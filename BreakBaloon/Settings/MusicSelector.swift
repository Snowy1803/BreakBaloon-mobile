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
        super.init(gvc: gvc, value: gvc.currentMusicInt)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateAfterValueChange() {
        gvc.currentMusicInt = value
        UserDefaults.standard.set(gvc.currentMusicFileName, forKey: "currentMusic")
        super.updateAfterValueChange()
        gvc.reloadBackgroundMusic()
    }
    
    override func maxValue() -> Int {
        GameViewController.getMusicURLs().count - 1
    }
    
    override func text() -> String {
        let cmps = GameViewController.getMusicURLs()[value].absoluteString.components(separatedBy: "/")
        return cmps[cmps.count - 1].components(separatedBy: ".")[0].removingPercentEncoding!
    }
}
