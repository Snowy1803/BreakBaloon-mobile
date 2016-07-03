//
//  GameViewController.swift
//  BreakBaloon
//
//  Created by Emil on 19/06/2016.
//  Copyright (c) 2016 Snowy_1803. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class GameViewController: UIViewController {
    static let DEFAULT_AUDIO:Float = 1.0
    static let DEFAULT_MUSIC:Float = 0.8
    
    var skView: SKView?
    
    var backgroundMusicPlayer:AVAudioPlayer = AVAudioPlayer()
    var audioPlayer:AVAudioPlayer = AVAudioPlayer()
    var audioVolume:Float = GameViewController.DEFAULT_AUDIO
    var currentGame:GameScene?
    var currentMusicFileName:String = "Race.m4a"
    var currentMusicInt:Int {
        get {
            for i in 0 ..< GameViewController.getMusicURLs().count {
                if GameViewController.getMusicURLs()[i].absoluteString.hasSuffix(currentMusicFileName) {
                    return i
                }
            }
            return GameViewController.getMusicURLs().count // Personnal
        }
        set(value) {
            if value < GameViewController.getMusicURLs().count {
                let cmps = GameViewController.getMusicURLs()[value].absoluteString.componentsSeparatedByString("/")
                currentMusicFileName = cmps[cmps.count - 1]
            } else {
                currentMusicFileName = "_personnal"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadMusicAndStartScene()
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).triggerDeepLinkIfPresent()
    }
    
    func loadMusicAndStartScene() {
        if GameViewController.getMusicURLs().isEmpty {
            do {
                try Downloadable(type: .M4aMusic, name: "Race", author: "Snowy", id: "Race.m4a", version: "x", description: "", gvc: self).download(nil, wait: true)
            } catch {
                print("Couldn't download content")
                getNil()! //Crash
            }
        }
        let data = NSUserDefaults.standardUserDefaults()
        if data.stringForKey("currentMusic") == nil {
            data.setObject("Race.m4a", forKey: "currentMusic")
        }
        if data.objectForKey("audio-true") == nil {
            data.setFloat(GameViewController.DEFAULT_MUSIC, forKey: "audio-true")
        }
        if data.objectForKey("audio-false") == nil {
            data.setFloat(GameViewController.DEFAULT_AUDIO, forKey: "audio-false")
        }
        currentMusicFileName = NSUserDefaults.standardUserDefaults().stringForKey("currentMusic")!
        let welcome:NSURL = NSBundle.mainBundle().URLForResource("Welcome", withExtension: "wav")!
        let bgMusicURL:NSURL = GameViewController.getMusicURL(currentMusicFileName)!
        
        do {
            try self.backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: bgMusicURL)
            try self.audioPlayer = AVAudioPlayer(contentsOfURL: welcome)
        } catch {
            
        }
        backgroundMusicPlayer.numberOfLoops = -1
        backgroundMusicPlayer.volume = data.floatForKey("audio-true")
        backgroundMusicPlayer.prepareToPlay()
        backgroundMusicPlayer.play()
        audioVolume = data.floatForKey("audio-false")
        audioPlayer.volume = audioVolume
        audioPlayer.prepareToPlay()
        audioPlayer.play()
        
        skView = (self.view as! SKView)
        //skView.showsFPS = true
        //skView.showsNodeCount = true
        skView!.ignoresSiblingOrder = true
        
        let scene:SKScene = StartScene(size: skView!.bounds.size)
        scene.scaleMode = .AspectFill
        skView!.presentScene(scene)
    }
    
    func getNil() -> Any? {
        return nil
    }
    
    func reloadBackgroundMusic() {
        currentMusicFileName = NSUserDefaults.standardUserDefaults().stringForKey("currentMusic")!
        let bgMusicURL:NSURL = GameViewController.getMusicURL(currentMusicFileName)!
        do {
            try self.backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: bgMusicURL)
        } catch {
            
        }
        backgroundMusicPlayer.numberOfLoops = -1
        backgroundMusicPlayer.volume = NSUserDefaults.standardUserDefaults().floatForKey("audio-true")
        backgroundMusicPlayer.prepareToPlay()
        backgroundMusicPlayer.play()
    }
    
    class func getMusicURLs() -> [NSURL] {
        var urls:[NSURL] = []
        let path = FileSaveHelper(fileName: "", fileExtension: .NONE).fullyQualifiedPath
        let enumerator = NSFileManager.defaultManager().enumeratorAtPath(path)
        
        while let element = enumerator?.nextObject() as? String {
            if(element.hasSuffix(".m4a")) {
                urls.append(NSURL(fileURLWithPath: "\(path)/\(element)"))
            }
        }
        return urls
        /*OLD
        for stringUrl in musicURL {
            urls.append(NSBundle.mainBundle().URLForResource(stringUrl, withExtension: "m4a")!)
        }
        return urls*/
    }
    
    class func getMusicURL(fileName:String) -> NSURL? {
        print("FILENAME:", fileName)
        if fileName == "_personnal" {
            return NSUserDefaults.standardUserDefaults().URLForKey("usermusic")
        }
        for url in getMusicURLs() {
            if url.absoluteString.hasSuffix("/\(fileName)") {
                return url
            }
        }
        return nil
    }

    override func shouldAutorotate() -> Bool {
        return false //else this is buggy
        //let skView:SKView = self.view as! SKView
        //return !(skView.scene is GameScene)
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
