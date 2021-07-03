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
        super.init(texture: texture, color: SKColor.clear, size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showImportDialog() {
        let media = MPMediaPickerController(mediaTypes: .music)
        media.allowsPickingMultipleItems = false
        media.delegate = self
        gvc.present(media, animated: true, completion: nil)
    }
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        if mediaItemCollection.count == 1 {
            gvc.dismiss(animated: true, completion: nil)
            let item = mediaItemCollection.items.first!
            UserDefaults.standard.set(item.title, forKey: "usermusicName")
            UserDefaults.standard.set(item.assetURL, forKey: "usermusic")
            selector!.setSelectorValue(selector!.maxValue())
        }
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        gvc.dismiss(animated: true, completion: nil)
    }
}
