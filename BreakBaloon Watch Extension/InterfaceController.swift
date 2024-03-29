//
//  InterfaceController.swift
//  BreakBaloon Watch Extension
//
//  Created by Emil on 06/10/2019.
//  Copyright © 2019 Snowy_1803. All rights reserved.
//

import Foundation
import WatchKit

class InterfaceController: WKInterfaceController {
    @IBOutlet var skInterface: WKInterfaceSKScene!
    
    var scene: WatchGameScene?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        
        scene = WatchGameScene()
        scene!.controller = self
            
        // Set the scale mode to scale to fit the window
        scene!.scaleMode = .aspectFill
        
        // Present the scene
        skInterface.presentScene(scene)
            
        // Use a value that will maintain a consistent frame rate
        skInterface.preferredFramesPerSecond = 30
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func onRecognizerStateChange(_ recognizer: WKLongPressGestureRecognizer) {
        if recognizer.state == .began {
            scene!.touchBegan(recognizer)
        }
    }
}
