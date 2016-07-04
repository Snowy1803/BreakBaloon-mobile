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

class MusicSelector: Selector, MPMediaPickerControllerDelegate {
    let importBtn = ImportMusic()
    
    init(gvc:GameViewController, importUnder:Bool) {
        super.init(gvc: gvc, value: gvc.currentMusicInt)
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
    
    func showImportDialog() {
        let media = MPMediaPickerController(mediaTypes: .Music)
        media.allowsPickingMultipleItems = false
        media.delegate = self
        gvc.presentViewController(media, animated: true, completion: nil)
    }
    
    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        if mediaItemCollection.count == 1 {
            gvc.dismissViewControllerAnimated(true, completion: nil)
            let item = mediaItemCollection.items.first!
            NSUserDefaults.standardUserDefaults().setObject(item.title, forKey: "usermusicName")
            NSUserDefaults.standardUserDefaults().setURL(item.assetURL, forKey: "usermusic")
            setSelectorValue(maxValue())
        }
    }
    
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
        gvc.dismissViewControllerAnimated(true, completion: nil)
    }
}