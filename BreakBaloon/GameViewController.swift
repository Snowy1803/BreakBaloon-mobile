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
    private static var loggedIn = false
    
    var skView: SKView?
    
    var backgroundMusicPlayer:AVAudioPlayer = AVAudioPlayer()
    var audioPlayer:AVAudioPlayer = AVAudioPlayer()
    var audioVolume:Float = GameViewController.DEFAULT_AUDIO
    var currentGame:AbstractGameScene?
    var currentMusicFileName = "Race.m4a"
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
    var currentTheme:Theme = Theme.themeList.first!
    var currentThemeInt:Int {
        get {
            return Theme.themeList.indexOf({theme in
                return theme.equals(currentTheme)
            })!
        }
        set(value) {
            currentTheme = Theme.themeList[value]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // INIT RANDOM BALOONS LEVELS
        for level in RandGameLevel.levels {
            level.open()
        }
        
        print("Path:", FileSaveHelper(fileName: "", fileExtension: .NONE).fullyQualifiedPath)
        loadMusicAndStartScene()
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).triggerDeepLinkIfPresent()
    }
    
    func loadMusicAndStartScene() {
        if GameViewController.getMusicURLs().isEmpty {
            do {
                try Downloadable(type: .M4aMusic, name: "Race", author: "Snowy", id: "Race.m4a", version: "x", description: "", levelRequirement: 0).download(nil, wait: true)
            } catch {
                print("Couldn't download content")
                getNil()! //Crash
            }
        }
        let data = NSUserDefaults.standardUserDefaults()
        if data.stringForKey("currentMusic") == nil {
            data.setObject("Race.m4a", forKey: "currentMusic")
        }
        if data.stringForKey("currentTheme") == nil {
            data.setObject("/Default", forKey: "currentTheme")
        }
        if data.objectForKey("audio-true") == nil {
            data.setFloat(GameViewController.DEFAULT_MUSIC, forKey: "audio-true")
        }
        if data.objectForKey("audio-false") == nil {
            data.setFloat(GameViewController.DEFAULT_AUDIO, forKey: "audio-false")
        }
        if NSUserDefaults.standardUserDefaults().objectForKey("elementalcube.sessid") != nil {
            logIn(sessid: NSUserDefaults.standardUserDefaults().stringForKey("elementalcube.sessid")!)
        }
        currentTheme = Theme.withID(NSUserDefaults.standardUserDefaults().stringForKey("currentTheme")!)!
        let welcome:NSURL = NSBundle.mainBundle().URLForResource("Welcome", withExtension: "wav")!
        
        do {
            try self.audioPlayer = AVAudioPlayer(contentsOfURL: welcome)
        } catch {
            print(error)
        }
        audioVolume = data.floatForKey("audio-false")
        audioPlayer.volume = audioVolume
        audioPlayer.prepareToPlay()
        audioPlayer.play()
        reloadBackgroundMusic()
        
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
        } catch let error as NSError {
            print("ERROR WHILE LOADING AUDIO FILE. REMOVING THE CORRUPTED AUDIO FILE. Error: \(error.localizedDescription)")
            do {
                try NSFileManager.defaultManager().removeItemAtURL(bgMusicURL)
            } catch let error as NSError {
                print("Couldn't delete the corrupted file. Error: \(error.localizedDescription)")
            }
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
    }
    
    class func getMusicURL(fileName:String) -> NSURL? {
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
    
    class func getExternalThemes() -> [NSURL] {
        let path = NSURL(fileURLWithPath: FileSaveHelper(fileName: "", fileExtension: .NONE).fullyQualifiedPath)
        return path.subdirectories
    }
    
    override func shouldAutorotate() -> Bool {
        return skView!.scene is StartScene && self.view.frame.width > 400
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
    
    class func getLevel() -> Int {
        return getTotalXP() / 250 + 1
    }
    
    class func getTotalXP() -> Int {
        return NSUserDefaults.standardUserDefaults().integerForKey("exp")
    }
    
    class func getLevelXP() -> Int {
        return getTotalXP() % 250
    }
    
    class func getLevelXPFloat() -> Float {
        return Float(getLevelXP()) / 250
    }
    
    func addXP(xp:Int) {
        let levelBefore = GameViewController.getLevel()
        NSUserDefaults.standardUserDefaults().setInteger(GameViewController.getTotalXP() + xp, forKey: "exp")
        print("Added \(xp) XP")
        if levelBefore < GameViewController.getLevel() {
            let alert = UIAlertController(title: NSLocalizedString("level.up.title", comment: ""), message: String(format: NSLocalizedString("level.up.text", comment: ""), GameViewController.getLevel()), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    class func isLoggedIn() -> Bool {
        return loggedIn
    }
    
    func logInDialog(username username: String? = nil, password: String? = nil, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: NSLocalizedString("login.title", comment: ""), message: NSLocalizedString("login.text", comment: ""), preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({ textField in
            textField.placeholder = NSLocalizedString("login.username.placeholder", comment: "")
            textField.text = username
        })
        alert.addTextFieldWithConfigurationHandler({ textField in
            textField.placeholder = NSLocalizedString("login.password.placeholder", comment: "")
            textField.text = password
            textField.secureTextEntry = true
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .Default, handler: {
            action in
            self.logIn(username: alert.textFields![0].text!, password: alert.textFields![1].text!, completion: completion)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func logIn(username username: String, password: String, completion: (() -> Void)? = nil) {
        logIn(query: "user=\(username)&passwd=\(password.sha1())", username: username, password: password, completion: completion)
    }
    
    func logIn(sessid sessid: String, completion: (() -> Void)? = nil) {
        logIn(query: "sessid=\(sessid)", completion: completion)
    }
    
    func logIn(query query: String, username: String? = nil, password: String? = nil, completion: (() -> Void)? = nil) {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://elementalcube.esy.es/api/auth.php")!)
        request.HTTPMethod = "POST"
        request.HTTPBody = query.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {
                print("[LOGIN] error=\(error)")
                return
            }
            
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {
                print("[LOGIN] status code: \(httpStatus.statusCode)")
                print("[LOGIN] response: \(response)")
            }
            dispatch_async(dispatch_get_main_queue()) {
                let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                let authStatus = responseString?.componentsSeparatedByString("\r\n")[0]
                if authStatus != nil {
                    let status = LoginStatus(rawValue: Int(authStatus!)!)
                    if status == .Authenticated {
                        let sessid = responseString!.componentsSeparatedByString("\r\n")[1]
                        NSUserDefaults.standardUserDefaults().setObject(sessid, forKey: "elementalcube.sessid")
                        GameViewController.loggedIn = true
                        if completion != nil {
                            completion!()
                        }
                    } else {
                        let alert = UIAlertController(title: NSLocalizedString("login.title", comment: ""), message: NSLocalizedString("login.error.\(String(status!))", comment: ""), preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .Default, handler: nil))
                        alert.addAction(UIAlertAction(title: NSLocalizedString("login.tryagain", comment: ""), style: .Default, handler: {
                            action in
                            if status == .InvalidUsername || status == .IncorrectPassword {
                                self.logInDialog(username: username, password: password)
                            } else {
                                self.logIn(query: query)
                            }
                        }))
                        self.presentViewController(alert, animated: true, completion: completion)
                    }
                }
            }
        }
        task.resume()
    }
    
    class func logOut() {
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "elementalcube.sessid")
        GameViewController.loggedIn = false
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition(nil, completion: {
            _ in
            if self.skView!.scene! is StartScene {
                self.skView!.scene!.size = size
                (self.skView!.scene! as! StartScene).adjustPosition(false, sizeChange: true)
            }
            
        })
    }
}

extension NSURL {
    var isDirectory: Bool {
        guard let path = path where fileURL else { return false }
        var bool: ObjCBool = false
        return NSFileManager().fileExistsAtPath(path, isDirectory: &bool) ? bool.boolValue : false
    }
    var subdirectories: [NSURL] {
        guard isDirectory else { return [] }
        do {
            return try NSFileManager.defaultManager()
                .contentsOfDirectoryAtURL(self, includingPropertiesForKeys: nil, options: [])
                .filter{ $0.isDirectory }
        } catch let error as NSError {
            print(error.localizedDescription)
            return []
        }
    }
    var content: [NSURL] {
        guard isDirectory else { return [] }
        do {
            return try NSFileManager.defaultManager()
                .contentsOfDirectoryAtURL(self, includingPropertiesForKeys: nil, options: [])
        } catch let error as NSError {
            print(error.localizedDescription)
            return []
        }
    }
}

extension String {
    func sha1() -> String {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)!
        var digest = [UInt8] (count: Int(CC_SHA1_DIGEST_LENGTH), repeatedValue: 0)
        CC_SHA1(data.bytes, CC_LONG(data.length), &digest)
        let hexBytes = digest.map{String(format: "%02hhx", $0)}
        return hexBytes.joinWithSeparator("")
    }
    
    func md5() -> String {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)!
        var digest = [UInt8] (count: Int(CC_MD5_DIGEST_LENGTH), repeatedValue: 0)
        CC_MD5(data.bytes, CC_LONG(data.length), &digest)
        let hexBytes = digest.map{String(format: "%02hhx", $0)}
        return hexBytes.joinWithSeparator("")
    }
}

enum LoginStatus: Int {
    case Authenticated = 1
    case InvalidUsername = -1
    case DBError = -2
    case InvalidSessID = -3
    case IncorrectPassword = -4
    case ProfileDeactivated = -5
}
