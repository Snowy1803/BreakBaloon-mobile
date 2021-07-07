//
//  GameViewController.swift
//  BreakBaloon
//
//  Created by Emil on 19/06/2016.
//  Copyright (c) 2016 Snowy_1803. All rights reserved.
//

import AVFoundation
import CommonCrypto
import GameKit
import SpriteKit
import UIKit
import WatchConnectivity

class GameViewController: UIViewController, WCSessionDelegate {
    static let defaultAudioVolume: Float = 1.0
    static let defaultMusicVolume: Float = 0.8
    
    var skView: SKView?
    
    var backgroundMusicPlayer: AVAudioPlayer!
    var audioPlayer: AVAudioPlayer!
    var audioVolume: Float = GameViewController.defaultAudioVolume
    var currentGame: AbstractGameScene?
    var currentMusicFileName = "Race.m4a"
    var currentMusicInt: Int {
        get {
            for i in 0..<GameViewController.getMusicURLs().count {
                if GameViewController.getMusicURLs()[i].absoluteString.hasSuffix(currentMusicFileName) {
                    return i
                }
            }
            return -1
        }
        set(value) {
            let cmps = GameViewController.getMusicURLs()[value].absoluteString.components(separatedBy: "/")
            currentMusicFileName = cmps[cmps.count - 1]
        }
    }

    var currentTheme: AbstractTheme = AbstractThemeUtils.themeList.first!
    var currentThemeInt: Int {
        get {
            AbstractThemeUtils.themeList.firstIndex(where: { theme in
                theme.id == currentTheme.id
            })!
        }
        set(value) {
            currentTheme = AbstractThemeUtils.themeList[value]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // INIT RANDOM BALOONS LEVELS
        for level in RandGameLevel.levels {
            level.load()
        }
        
        print("Path:", FileSaveHelper(fileName: "", fileExtension: .none).fullyQualifiedPath)
        loadMusicAndStartScene()
        
        _ = UIApplication.shared.appDelegate.triggerDeepLinkIfPresent()

        if WCSession.isSupported() {
            print("Activating Watch Connectivity")
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func loadMusicAndStartScene() {
        if GameViewController.getMusicURLs().isEmpty {
            do {
                try Downloadable(type: .m4aMusic, name: "Race", author: "Snowy", id: "Race.m4a", version: "x", description: "", levelRequirement: 0).download(nil, wait: true)
            } catch {
                print("Couldn't download content")
                fatalError()
            }
        }
        let data = UserDefaults.standard
        if data.string(forKey: "currentMusic") == nil {
            data.set("Race.m4a", forKey: "currentMusic")
        }
        if data.string(forKey: "currentTheme") == nil {
            data.set("/Default", forKey: "currentTheme")
        }
        if data.object(forKey: "audio-true") == nil {
            data.set(GameViewController.defaultMusicVolume, forKey: "audio-true")
        }
        if data.object(forKey: "audio-false") == nil {
            data.set(GameViewController.defaultAudioVolume, forKey: "audio-false")
        }
        if UserDefaults.standard.object(forKey: "elementalcube.sessid") != nil {
            ECLoginManager.shared.logIn(sessid: UserDefaults.standard.string(forKey: "elementalcube.sessid")!, delegate: nil)
        }
        currentTheme = AbstractThemeUtils.withID(UserDefaults.standard.string(forKey: "currentTheme")!)!
        let welcome: URL = Bundle.main.url(forResource: "Welcome", withExtension: "wav")!
        
        print(UserDefaults.standard.dictionaryRepresentation())
        do {
            print(try FileManager.default.contentsOfDirectory(atPath: FileSaveHelper(fileName: "", fileExtension: .none).fullyQualifiedPath))
        } catch let error as NSError {
            print("Couldn't view documents. Error: \(error.localizedDescription)")
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: welcome)
        } catch {
            print(error)
        }
        audioVolume = data.float(forKey: "audio-false")
        audioPlayer.volume = audioVolume
        audioPlayer.prepareToPlay()
        audioPlayer.play()
        reloadBackgroundMusic()
        
        // (enforced by storyboard)
        // swiftlint:disable:next force_cast
        skView = (view as! SKView)
        #if DEBUG
            skView!.showsFPS = true
            skView!.showsNodeCount = true
        #endif
        skView!.ignoresSiblingOrder = true
        skView!.preferredFramesPerSecond = 120
        
        let scene: SKScene = StartScene(size: skView!.bounds.size)
        scene.scaleMode = .aspectFill
        skView!.presentScene(scene)
        
        // Game Center setup
        GKLocalPlayer.local.authenticateHandler = { [unowned self] viewController, error in
            if let viewController = viewController {
                present(viewController, animated: true)
            } else if let error = error {
                print("Game Center auth failed")
                print(error)
            } else {
                print("Game Center authenticated!")
            }
        }
    }
    
    func reloadBackgroundMusic() {
        currentMusicFileName = UserDefaults.standard.string(forKey: "currentMusic")!
        let bgMusicURL: URL = GameViewController.getMusicURL(currentMusicFileName)!
        do {
            try backgroundMusicPlayer = AVAudioPlayer(contentsOf: bgMusicURL)
        } catch let error as NSError {
            print("ERROR WHILE LOADING AUDIO FILE. REMOVING THE CORRUPTED AUDIO FILE. Error: \(error.localizedDescription)")
            do {
                try FileManager.default.removeItem(at: bgMusicURL)
            } catch let error as NSError {
                print("Couldn't delete the corrupted file. Error: \(error.localizedDescription)")
            }
            UserDefaults.standard.set("Race.m4a", forKey: "currentMusic")
        }
        backgroundMusicPlayer.numberOfLoops = -1
        backgroundMusicPlayer.volume = UserDefaults.standard.float(forKey: "audio-true")
        backgroundMusicPlayer.prepareToPlay()
        backgroundMusicPlayer.play()
    }
    
    class func getMusicURLs() -> [URL] {
        var urls: [URL] = []
        let path = FileSaveHelper(fileName: "", fileExtension: .none).fullyQualifiedPath
        let enumerator = FileManager.default.enumerator(atPath: path)
        
        while let element = enumerator?.nextObject() as? String {
            if element.hasSuffix(".m4a") {
                urls.append(URL(fileURLWithPath: "\(path)/\(element)"))
            }
        }
        print(urls)
        return urls
    }
    
    class func getMusicURL(_ fileName: String) -> URL? {
        for url in getMusicURLs() {
            if url.absoluteString.hasSuffix("/\(fileName)") {
                return url
            }
        }
        return nil
    }
    
    class func getExternalThemes() -> [URL] {
        let path = URL(fileURLWithPath: FileSaveHelper(fileName: "", fileExtension: .none).fullyQualifiedPath)
        return path.subdirectories
    }
    
    override var shouldAutorotate: Bool {
        skView!.scene is StartScene && self.view.frame.width > 400
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden: Bool {
        false
    }
    
    func addXP(_ xp: Int) {
        let levelBefore = PlayerProgress.current.currentLevel
        PlayerProgress.current.totalXP += xp
        print("Added \(xp) XP")
        if levelBefore < PlayerProgress.current.currentLevel {
            let alert = UIAlertController(title: NSLocalizedString("level.up.title", comment: ""), message: String(format: NSLocalizedString("level.up.text", comment: ""), PlayerProgress.current.currentLevel), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        if WCSession.isSupported() {
            WCSession.default.transferUserInfo(["exp": PlayerProgress.current.totalXP])
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        print("receive raw: \(userInfo)")
        guard let exp = userInfo["exp"] as? Int else {
            return
        }
        if PlayerProgress.current.totalXP <= exp {
            PlayerProgress.current.totalXP = exp
            if let start = skView?.scene as? StartScene {
                start.growXP()
            }
        } else {
            session.transferUserInfo(["exp": PlayerProgress.current.totalXP])
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith _: WCSessionActivationState, error _: Error?) {
        session.transferUserInfo(["exp": PlayerProgress.current.totalXP])
    }
    
    func session(_: WCSession, didFinish _: WCSessionUserInfoTransfer, error: Error?) {
        if let error = error {
            print("transfer failed", error)
        } else {
            print("successful transfer")
        }
    }
    
    func sessionDidBecomeInactive(_: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("changed watch")
        session.activate()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            if let scene = self.skView!.scene as? StartScene {
                self.skView!.scene!.size = size
                scene.adjustPosition(false, sizeChange: true)
            }
        }, completion: nil)
    }
}

extension URL {
    var isDirectory: Bool {
        var bool: ObjCBool = false
        return FileManager.default.fileExists(atPath: path, isDirectory: &bool) ? bool.boolValue : false
    }

    var subdirectories: [URL] {
        guard isDirectory else { return [] }
        do {
            return try FileManager.default
                .contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [])
                .filter(\.isDirectory)
        } catch let error as NSError {
            print(error.localizedDescription)
            return []
        }
    }

    var content: [URL] {
        guard isDirectory else { return [] }
        do {
            return try FileManager.default
                .contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [])
        } catch let error as NSError {
            print(error.localizedDescription)
            return []
        }
    }
}

extension String {
    func sha1() -> String {
        let data = self.data(using: String.Encoding.utf8)!
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        CC_SHA1((data as NSData).bytes, CC_LONG(data.count), &digest)
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined(separator: "")
    }
    
    func md5() -> String {
        let data = self.data(using: String.Encoding.utf8)!
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5((data as NSData).bytes, CC_LONG(data.count), &digest)
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined(separator: "")
    }
}

extension SKColor {
    convenience init(rgbValue: UInt) {
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension UIImage {
    func withSize(_ newWidth: CGFloat) -> UIImage {
        if size.width == newWidth {
            return self
        }
        let scale = newWidth / size.width
        let newHeight = size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
