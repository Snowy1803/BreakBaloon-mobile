//
//  ExtensionDelegate.swift
//  BreakBaloon Watch Extension
//
//  Created by Emil on 06/10/2019.
//  Copyright © 2019 Snowy_1803. All rights reserved.
//

import WatchConnectivity
import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
    private var backgroundTasks: [WKWatchConnectivityRefreshBackgroundTask] = []
    
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                let session = WCSession.default
                print("Waking up for connectivity background task")
                if session.delegate == nil {
                    session.delegate = self
                    session.activate()
                }
                self.backgroundTasks.append(connectivityTask)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
    
    func session(_: WCSession, activationDidCompleteWith _: WCSessionActivationState, error _: Error?) {}
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        print("receive raw: \(userInfo)")
        if let exp = userInfo["exp"] as? Double {
            if UserDefaults.standard.double(forKey: "exp") <= exp {
                UserDefaults.standard.set(exp, forKey: "exp")
                print("Received XP:", exp)
            } else {
                session.transferUserInfo(["exp": UserDefaults.standard.double(forKey: "exp")])
            }
        }
        if let animate = userInfo["extension.animation.enabled"] as? Bool {
            UserDefaults.standard.set(animate, forKey: "extension.animation.enabled")
        }
        if !backgroundTasks.isEmpty, !session.hasContentPending {
            backgroundTasks.removeAll {
                $0.setTaskCompletedWithSnapshot(false)
                return true
            }
        }
    }
}
