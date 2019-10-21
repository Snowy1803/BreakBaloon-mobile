//
//  InterfaceController.swift
//  BreakBaloon Watch Extension
//
//  Created by Emil on 06/10/2019.
//  Copyright © 2019 Snowy_1803. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet var skInterface: WKInterfaceSKScene!
    
    var scene: WatchGameScene?
    
    var wcSession: WCSession!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        
        scene = WatchGameScene()
        scene!.controller = self
            
        // Set the scale mode to scale to fit the window
        scene!.scaleMode = .aspectFill
        
        // Present the scene
        self.skInterface.presentScene(scene)
            
        
        // Use a value that will maintain a consistent frame rate
        self.skInterface.preferredFramesPerSecond = 30
    
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        wcSession = WCSession.default
        wcSession.delegate = self
        wcSession.activate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        let exp = userInfo["exp"] as? Int
        if exp != nil {
            if UserDefaults.standard.integer(forKey: "exp") < exp! {
                UserDefaults.standard.set(exp!, forKey: "exp")
                print("Received XP:", exp!)
            } else {
                session.transferUserInfo(["exp": UserDefaults.standard.integer(forKey: "exp")])
            }
        }
        let animate = userInfo["extension.animation.enabled"] as? Bool
        if animate != nil {
            UserDefaults.standard.set(animate, forKey: "extension.animation.enabled")
        }
    }
    
    @IBAction func onRecognizerStateChange(_ recognizer: WKLongPressGestureRecognizer) {
        if recognizer.state == .began {
            scene!.touchBegan(recognizer)
        }
    }
}
