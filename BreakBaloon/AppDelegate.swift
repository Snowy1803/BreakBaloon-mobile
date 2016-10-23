//
//  AppDelegate.swift
//  BreakBaloon
//
//  Created by Emil on 19/06/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var loadedEnoughToDeepLink = false
    var deepLink:RemoteNotificationDeepLink?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
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
    
    func application(_ application: UIApplication, open openURL: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if openURL.host != nil {
            let url = openURL.absoluteString
            let queryArray:[String] = url.components(separatedBy: "/")
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
                    let query:[String] = Array(queryArray[3..<queryArray.count])
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
            let userInfo = [query : parameter]
            self.applicationHandleRemoteNotification(application, didReceiveRemoteNotification: userInfo)
        }
        return true
    }
    
    func applicationHandleRemoteNotification(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if application.applicationState == .background || application.applicationState == .inactive {
            self.deepLink = RemoteNotificationDeepLink.create(userInfo)
            if loadedEnoughToDeepLink {
                self.triggerDeepLinkIfPresent()
            }
        }
    }
    
    func triggerDeepLinkIfPresent() -> Bool {
        loadedEnoughToDeepLink = true
        let ret = (self.deepLink?.trigger() != nil)
        self.deepLink = nil
        return ret
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        let gvc:GameViewController = self.window!.rootViewController as! GameViewController
        if gvc.currentGame != nil {
            gvc.currentGame!.pauseGame()
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        let gvc:GameViewController = self.window!.rootViewController as! GameViewController
        if gvc.currentGame != nil {
            gvc.currentGame!.quitPause()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(handleQuickAction(application, shortcutItem))
    }
    
    @available(iOS 9.0, *)
    func handleQuickAction(_ application:UIApplication, _ shortcut: UIApplicationShortcutItem) -> Bool {
        var quickActionHandled = false
        let type = shortcut.type.components(separatedBy: ".").last!
        if let shortcutType = QuickActions.init(rawValue: type) {
            switch shortcutType {
            case .Singleplayer:
                self.applicationHandleRemoteNotification(application, didReceiveRemoteNotification: ["game" : "singleplayer"])
            case .Computer:
                self.applicationHandleRemoteNotification(application, didReceiveRemoteNotification: ["game" : "computer"])
            case .Time:
                self.applicationHandleRemoteNotification(application, didReceiveRemoteNotification: ["game" : "time"])
            }
            quickActionHandled = true
        }
        return quickActionHandled
    }
    
    enum QuickActions: String {
        case Singleplayer = "Singleplayer"
        case Computer = "Computer"
        case Time = "Time"
    }
}

