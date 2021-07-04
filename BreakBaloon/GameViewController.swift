//
//  GameViewController.swift
//  BreakBaloon
//
//  Created by Emil on 19/06/2016.
//  Copyright (c) 2016 Snowy_1803. All rights reserved.
//

import AVFoundation
import CommonCrypto
import SpriteKit
import UIKit
import WatchConnectivity

class GameViewController: UIViewController, WCSessionDelegate {
    static let defaultAudioVolume: Float = 1.0
    static let defaultMusicVolume: Float = 0.8
    fileprivate static var loggedIn = false
    
    var skView: SKView?
    
    var wcSession: WCSession?
    
    var backgroundMusicPlayer: AVAudioPlayer!
    var audioPlayer: AVAudioPlayer!
    var audioVolume: Float = GameViewController.defaultAudioVolume
    var currentGame: AbstractGameScene?
    var currentMusicFileName = "Race.m4a"
    var currentMusicInt: Int {
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
                let cmps = GameViewController.getMusicURLs()[value].absoluteString.components(separatedBy: "/")
                currentMusicFileName = cmps[cmps.count - 1]
            } else {
                currentMusicFileName = "_personnal"
            }
        }
    }

    var currentTheme: AbstractTheme = AbstractThemeUtils.themeList.first!
    var currentThemeInt: Int {
        get {
            return AbstractThemeUtils.themeList.firstIndex(where: { theme in
                theme.equals(currentTheme)
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
            level.open()
        }
        
        print("Path:", FileSaveHelper(fileName: "", fileExtension: .none).fullyQualifiedPath)
        loadMusicAndStartScene()
        
        _ = UIApplication.shared.appDelegate.triggerDeepLinkIfPresent()

        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession!.delegate = self
            wcSession!.activate()
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
            logIn(sessid: UserDefaults.standard.string(forKey: "elementalcube.sessid")!)
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
        // skView.showsFPS = true
        // skView.showsNodeCount = true
        skView!.ignoresSiblingOrder = true
        
        let scene: SKScene = StartScene(size: skView!.bounds.size)
        scene.scaleMode = .aspectFill
        skView!.presentScene(scene)
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
        if fileName == "_personnal" {
            return UserDefaults.standard.url(forKey: "usermusic")
        }
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
        return skView!.scene is StartScene && self.view.frame.width > 400
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
        return false
    }
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return .all
    }
    
    class func getLevel() -> Int {
        return getTotalXP() / 250 + 1
    }
    
    class func getTotalXP() -> Int {
        return UserDefaults.standard.integer(forKey: "exp")
    }
    
    class func getLevelXP() -> Int {
        return getTotalXP() % 250
    }
    
    class func getLevelXPFloat() -> Float {
        return Float(getLevelXP()) / 250
    }
    
    func addXP(_ xp: Int) {
        let levelBefore = GameViewController.getLevel()
        UserDefaults.standard.set(GameViewController.getTotalXP() + xp, forKey: "exp")
        print("Added \(xp) XP")
        if levelBefore < GameViewController.getLevel() {
            let alert = UIAlertController(title: NSLocalizedString("level.up.title", comment: ""), message: String(format: NSLocalizedString("level.up.text", comment: ""), GameViewController.getLevel()), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        wcSession?.transferUserInfo(["exp": GameViewController.getTotalXP() + xp])
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        let exp = userInfo["exp"] as? Int
        if exp != nil && GameViewController.getTotalXP() < exp! {
            UserDefaults.standard.set(exp!, forKey: "exp")
        } else {
            session.transferUserInfo(["exp": GameViewController.getTotalXP()])
        }
    }
    
    func session(_: WCSession, activationDidCompleteWith _: WCSessionActivationState, error _: Error?) {}
    
    func sessionDidBecomeInactive(_: WCSession) {}
    
    func sessionDidDeactivate(_: WCSession) {}
    
    class func isLoggedIn() -> Bool {
        return loggedIn
    }
    
    func logInDialog(username: String? = nil, password: String? = nil, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: NSLocalizedString("login.title", comment: ""), message: NSLocalizedString("login.text", comment: ""), preferredStyle: .alert)
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = NSLocalizedString("login.username.placeholder", comment: "")
            textField.text = username
        })
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = NSLocalizedString("login.password.placeholder", comment: "")
            textField.text = password
            textField.isSecureTextEntry = true
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { _ in
            self.logIn(username: alert.textFields![0].text!, password: alert.textFields![1].text!, completion: completion)
        })
        present(alert, animated: true, completion: nil)
    }
    
    func logIn(username: String, password: String, completion: (() -> Void)? = nil) {
        logIn(query: "user=\(username)&passwd=\(password)&v2&appid=ibb", username: username, password: password, completion: completion)
    }
    
    func logIn(sessid: String, completion: (() -> Void)? = nil) {
        logIn(query: "sessid=\(sessid)", completion: completion)
    }
    
    func logIn(query: String, username: String? = nil, password: String? = nil, completion: (() -> Void)? = nil) {
        let request = NSMutableURLRequest(url: URL(string: "http://elementalcube.infos.st/api/auth.php")!)
        request.httpMethod = "POST"
        request.httpBody = query.data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil, data != nil else {
                print("[LOGIN] error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("[LOGIN] status code: \(httpStatus.statusCode)")
                print("[LOGIN] response: \(String(describing: response))")
            }
            DispatchQueue.main.async {
                let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                let authStatus = responseString?.components(separatedBy: "\r\n")[0]
                if authStatus != nil, Int(authStatus!) != nil {
                    let status = LoginStatus(rawValue: Int(authStatus!)!)
                    if status == .authenticated {
                        let sessid = responseString!.components(separatedBy: "\r\n")[1]
                        UserDefaults.standard.set(sessid, forKey: "elementalcube.sessid")
                        GameViewController.loggedIn = true
                        if completion != nil {
                            completion!()
                        }
                    } else if status == .tfaRequired {
                        let alert = UIAlertController(title: NSLocalizedString("login.title", comment: ""), message: NSLocalizedString("login.error.\(String(describing: status!))", comment: ""), preferredStyle: .alert)
                        alert.addTextField(configurationHandler: { textField in
                            textField.placeholder = NSLocalizedString("login.2fa.placeholder", comment: "")
                        })
                        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
                        alert.addAction(UIAlertAction(title: NSLocalizedString("login.title", comment: ""), style: .default) { _ in
                            self.logIn(query: "\(query)&code=\(alert.textFields![0].text!)")
                        })
                        self.present(alert, animated: true, completion: completion)
                    } else {
                        let alert = UIAlertController(title: NSLocalizedString("login.title", comment: ""), message: NSLocalizedString("login.error.\(String(describing: status!))", comment: ""), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: nil))
                        alert.addAction(UIAlertAction(title: NSLocalizedString("login.tryagain", comment: ""), style: .default) { _ in
                            if status == .invalidUsername || status == .incorrectPassword {
                                self.logInDialog(username: username, password: password)
                            } else {
                                self.logIn(query: query)
                            }
                        })
                        self.present(alert, animated: true, completion: completion)
                    }
                }
            }
        })
        task.resume()
    }
    
    class func logOut() {
        UserDefaults.standard.set(nil, forKey: "elementalcube.sessid")
        GameViewController.loggedIn = false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil, completion: { _ in
            if let scene = self.skView!.scene as? StartScene {
                self.skView!.scene!.size = size
                scene.adjustPosition(false, sizeChange: true)
            }
        })
    }
}

extension URL {
    var isDirectory: Bool {
        var bool: ObjCBool = false
        return FileManager().fileExists(atPath: path, isDirectory: &bool) ? bool.boolValue : false
    }

    var subdirectories: [URL] {
        guard isDirectory else { return [] }
        do {
            return try FileManager.default
                .contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [])
                .filter { $0.isDirectory }
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

extension Float {
    static func random() -> Float {
        return Float(arc4random()) / Float(UINT32_MAX)
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX)
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

enum LoginStatus: Int {
    case authenticated = 1
    case invalidUsername = -1
    case dbError = -2
    case invalidSessID = -3
    case incorrectPassword = -4
    case profileDeactivated = -5
    case tfaRequired = -6
}
