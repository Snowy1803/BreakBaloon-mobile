//
//  AppDelegate.swift
//  BreakBaloon
//
//  Created by Emil on 19/06/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import AVFoundation
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var loadedEnoughToDeepLink = false
    var deepLink: RemoteNotificationDeepLink?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, policy: .default, options: .mixWithOthers)
        } catch {
            print(error)
        }
        return true
    }
    
    func application(_: UIApplication, open url: URL, options _: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        if url.path.hasSuffix(".m4a") {
            do {
                try FileManager.default.moveItem(at: url, to: URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]))
                return true
            } catch {
                print(error)
            }
        }
        return false
    }
    
    func application(_ application: UIApplication, open openURL: URL, sourceApplication _: String?, annotation _: Any) -> Bool {
        if openURL.host != nil {
            let url = openURL.absoluteString
            let queryArray: [String] = url.components(separatedBy: "/")
            let query = queryArray[2]
            var parameter = ""
            
            if query == "settings" {
                parameter = "global"
                if queryArray.count > 3 {
                    parameter = queryArray[3]
                }
            } else if query == "game" {
                parameter = "singleplayer"
                if queryArray.count > 3 {
                    let query: [String] = Array(queryArray[3..<queryArray.count])
                    parameter = query.joined(separator: "/")
                }
            } else if query == "bbstore" {
                parameter = "none"
                if queryArray.count > 3 {
                    parameter = queryArray[3]
                }
            } else {
                return true
            }
            let userInfo = [query: parameter]
            applicationHandleRemoteNotification(application, didReceiveRemoteNotification: userInfo)
        }
        return true
    }
    
    func applicationHandleRemoteNotification(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if application.applicationState == .background || application.applicationState == .inactive {
            deepLink = RemoteNotificationDeepLink.create(userInfo)
            if loadedEnoughToDeepLink {
                _ = triggerDeepLinkIfPresent()
            }
        }
    }
    
    func triggerDeepLinkIfPresent() -> Bool {
        loadedEnoughToDeepLink = true
        let ret = (deepLink?.trigger() != nil)
        deepLink = nil
        return ret
    }

    func applicationWillResignActive(_: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        guard let gvc = UIApplication.shared.keyWindow?.gvc else {
            return
        }
        if gvc.currentGame != nil {
            gvc.currentGame!.pauseGame()
        }
    }

    func applicationDidEnterBackground(_: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        guard let gvc = UIApplication.shared.keyWindow?.gvc else {
            return
        }
        if gvc.currentGame != nil {
            gvc.currentGame!.quitPause()
        }
    }

    func applicationWillTerminate(_: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(handleQuickAction(application, shortcutItem))
    }
    
    @available(iOS 9.0, *)
    func handleQuickAction(_ application: UIApplication, _ shortcut: UIApplicationShortcutItem) -> Bool {
        var quickActionHandled = false
        let type = shortcut.type.components(separatedBy: ".").last!
        if let shortcutType = QuickActions(rawValue: type) {
            switch shortcutType {
            case .singleplayer:
                applicationHandleRemoteNotification(application, didReceiveRemoteNotification: ["game": "singleplayer"])
            case .computer:
                applicationHandleRemoteNotification(application, didReceiveRemoteNotification: ["game": "computer"])
            case .time:
                applicationHandleRemoteNotification(application, didReceiveRemoteNotification: ["game": "time"])
            }
            quickActionHandled = true
        }
        return quickActionHandled
    }
    
    enum QuickActions: String {
        case singleplayer = "Singleplayer"
        case computer = "Computer"
        case time = "Time"
    }
}

extension UIApplication {
    var appDelegate: AppDelegate! {
        delegate as? AppDelegate
    }
}

extension UIView {
    var gvc: GameViewController! {
        window?.rootViewController as? GameViewController
    }
}
