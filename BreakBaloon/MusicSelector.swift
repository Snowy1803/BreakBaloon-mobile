//
//  MusicSelector.swift
//  BreakBaloon
//
//  Created by Emil on 26/06/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit
import MediaPlayer

class MusicSelector: Selector {
    let importBtn: ImportMusic
    
    init(gvc:GameViewController, importUnder:Bool) {
        importBtn = ImportMusic(gvc: gvc)
        super.init(gvc: gvc, value: gvc.currentMusicInt)
        importBtn.selector = self
        if importUnder {
            importBtn.position = CGPointMake(0, -(self.frame.height / 4 + importBtn.frame.width / 4))
        } else {
            importBtn.position = CGPointMake(self.frame.width / 4 + importBtn.frame.width / 4, 0)
        }
        addChild(importBtn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateAfterValueChange() {
        gvc.currentMusicInt = value
        NSUserDefaults.standardUserDefaults().setObject(gvc.currentMusicFileName, forKey: "currentMusic")
        super.updateAfterValueChange()
        gvc.reloadBackgroundMusic()
    }
    
    override func maxValue() -> Int {
        return GameViewController.getMusicURLs().count - (NSUserDefaults.standardUserDefaults().objectForKey("usermusic") == nil ? 1 : 0)
    }
    
    override func text() -> String {
        if value == GameViewController.getMusicURLs().count {
            let name = NSUserDefaults.standardUserDefaults().stringForKey("usermusicName")
            return name == nil ? "Custom" : name!
        }
        let cmps = GameViewController.getMusicURLs()[value].absoluteString.componentsSeparatedByString("/")
        return cmps[cmps.count - 1].componentsSeparatedByString(".")[0].stringByRemovingPercentEncoding!
    }
}