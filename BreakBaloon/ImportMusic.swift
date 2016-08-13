//
//  ImportMusic.swift
//  BreakBaloon
//
//  Created by Emil on 30/06/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit
import MediaPlayer

class ImportMusic: SKSpriteNode, MPMediaPickerControllerDelegate {
    let gvc: GameViewController
    var selector: MusicSelector?
    
    init(gvc: GameViewController) {
        self.gvc = gvc
        let texture = SKTexture(imageNamed: "import")
        super.init(texture: texture, color: SKColor.clearColor(), size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            selector!.setSelectorValue(selector!.maxValue())
        }
    }
    
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
        gvc.dismissViewControllerAnimated(true, completion: nil)
    }
}