//
//  BBStoreScene.swift
//  BreakBaloon
//
//  Created by Emil on 27/06/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import SpriteKit

class BBStoreScene: SKScene {
    let start:StartScene
    let gvc:GameViewController
    var downloads: [Downloadable]?
    var loading:SKLabelNode
    var errored = false
    var lastTouch:CGPoint?
    var touchBegin:CGPoint?
    var touchInterval:NSTimeInterval?
    private var decY:CGFloat = 0
    var title = SKLabelNode()
    var back = SKLabelNode()
    var upper = SKShapeNode()
    
    convenience init(start: StartScene) {
        self.init(start: start, size: start.view!.frame.size, gvc: (start.view?.window?.rootViewController as! GameViewController))
    }
    
    init(start: StartScene, size: CGSize, gvc:GameViewController) {
        self.start = start
        self.gvc = gvc
        
        loading = SKLabelNode(text: NSLocalizedString("bbstore.loading", comment: "Loading text"))
        loading.fontColor = SKColor.blackColor()
        
        super.init(size: size)
        self.backgroundColor = SKColor.whiteColor()
        loading.position = CGPointMake(self.frame.width / 2, self.frame.height / 2 - 10)
        addChild(loading)
        beginBBStoreLoading()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func beginBBStoreLoading() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            do {
                self.downloads = try Downloadable.loadAll(self.size, self.gvc)
                dispatch_async(dispatch_get_main_queue()) {
                    self.loading.runAction(SKAction.sequence([SKAction.fadeOutWithDuration(1), SKAction.removeFromParent()]))
                    for dl in self.downloads! {
                        dl.alpha = 0
                        self.addChild(dl)
                        dl.runAction(SKAction.fadeInWithDuration(1))
                    }
                    self.title = SKLabelNode(text: NSLocalizedString((UIDevice.currentDevice().userInterfaceIdiom != .Pad ? "bbstore.button" : "bbstore.title"), comment: "BBStore"))
                    self.title.fontColor = SKColor.blackColor()
                    self.title.fontSize = 20
                    self.title.position = CGPointMake(self.frame.width/2, self.frame.height - 25)
                    self.title.alpha = 0
                    self.title.zPosition = 6
                    self.addChild(self.title)
                    self.title.runAction(SKAction.fadeInWithDuration(1))
                    self.back.text = UIDevice.currentDevice().orientation.isLandscape ? NSLocalizedString("back", comment: "") : "⬅︎  "
                    self.back.fontColor = SKColor.blackColor()
                    self.back.fontSize = 20
                    self.back.position = CGPointMake(self.back.frame.width/2 + 5, self.frame.height - 25)
                    self.back.alpha = 0
                    self.back.zPosition = 7
                    self.addChild(self.back)
                    self.back.runAction(SKAction.fadeInWithDuration(1))
                    self.upper = SKShapeNode(rect: CGRectMake(0, self.frame.height - 30, self.frame.width, 30))
                    self.upper.fillColor = SKColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
                    self.upper.alpha = 0.75
                    self.upper.zPosition = 5
                    self.addChild(self.upper)
                }
            } catch {
                dispatch_async(dispatch_get_main_queue()) {
                    self.loading.text = NSLocalizedString("bbstore.error", comment: "Error text")
                    self.errored = true
                    let errorInfo = SKLabelNode(text: (error as NSError).localizedDescription)
                    errorInfo.position = CGPointMake(self.loading.position.x, self.loading.position.y - 30)
                    errorInfo.fontColor = SKColor.blackColor()
                    self.addChild(errorInfo)
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if errored {
            goBack()
        }
        if decY < 0 {
            if decY < -100 {
                title.runAction(SKAction.fadeOutWithDuration(NSTimeInterval(0.1)))
                back.runAction(SKAction.fadeOutWithDuration(NSTimeInterval(0.1)))
                upper.runAction(SKAction.fadeOutWithDuration(NSTimeInterval(0.1)))
                let transition = SKTransition.pushWithDirection(.Down, duration: NSTimeInterval((self.view!.frame.height + decY) * (CGFloat(NSDate().timeIntervalSince1970 - touchInterval!) / -decY)))
                transition.pausesOutgoingScene = false
                view?.presentScene(BBStoreScene(start: start, size: view!.frame.size, gvc: gvc), transition: transition)
            } else {
                decalageY(decY)
            }
        }
        if touches.count == 1 {
            let point = touches.first!.locationInNode(self)
            if back.frame.contains(point) {
                goBack()
            } else if downloads != nil && point.x + 10 > touchBegin!.x && point.x - 10 < touchBegin!.x && point.y + 10 > touchBegin!.y && point.y - 10 < touchBegin!.y {
                for dl in downloads! {
                    if dl.rect.frame.contains(touches.first!.locationInNode(dl)) {
                        dl.click(self)
                        break
                    }
                }
            }
            
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //if transition == false {
            let point = touches.first?.locationInNode(self)
            if touches.count == 1 && downloads != nil {
                decalageY(lastTouch!.y - point!.y)
            }
            lastTouch = point
        //}
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touches.count == 1 {
            lastTouch = touches.first?.locationInNode(self)
            touchBegin = touches.first?.locationInNode(self)
            touchInterval = NSDate().timeIntervalSince1970
        }
    }
    
    func decalageY(decY:CGFloat) {
        self.decY -= decY
        
        for dl in downloads! {
            dl.position.y -= decY
        }
    }
    
    func goBack() {
        self.view?.presentScene(start, transition: SKTransition.doorsOpenVerticalWithDuration(NSTimeInterval(1)))
    }
    
    func simulateClickOnDownload(id:String) {
        while downloads == nil {}
        for dl in downloads! {
            if dl.dlid == id {
                print("Simulating download of \(dl.name)")
                dl.click(self)
            }
        }
    }
}