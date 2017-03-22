//
//  AppDelegate.swift
//  zerokitiosdemo
//
//  Created by Tom Keller on 06/03/17.
//  Copyright © 2017 Wanari Ltd. All rights reserved.
//

import UIKit
import ZeroKit
import XCGLogger
import Firebase

let log: XCGLogger = {
    let log = XCGLogger(identifier: "advancedLogger", includeDefaultDestinations: false)
    
    // Create a destination for the system console log (via NSLog)
    let systemDestination = AppleSystemLogDestination(identifier: "advancedLogger.systemDestination")
    
    // Optionally set some configuration options
    systemDestination.outputLevel = .debug
    systemDestination.showLogIdentifier = false
    systemDestination.showFunctionName = true
    systemDestination.showThreadName = true
    systemDestination.showLevel = true
    systemDestination.showFileName = true
    systemDestination.showLineNumber = true
    systemDestination.showDate = true
    
    // Add the destination to the logger
    log.add(destination: systemDestination)
    
    // Add basic app info, version info etc, to the start of the logs
    log.logAppDetails()
    
    return log
}()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let _ = log
        
        ZeroManager.shared.initKit()
        
        DatabaseManager.shared.initDatabase()
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        log.debug("Host: \(url.host), path: \(url.path)")
        if let host = url.host {
            let path = url.path
            if host == APIConstants.INVITATION_HOST, path == APIConstants.INVITATION_PATH {
                handleInvitation(url: url)
            }
        }
        return true
    }
    
    func handleInvitation(url: URL) {
        let split = url.absoluteString.components(separatedBy: "#")
        if split.count > 0 {
            let secret = split.last!
            ZeroManager.shared.zeroKit?.getInvitationLinkInfo(with: secret, completion: { (linkInfo, error) in
                guard error == nil else {
                    log.error("Couldn't get invitation link info: \(error?.localizedDescription)")
                    return
                }
                self.topViewController()?.handleInvitation(invitationInfo: linkInfo!)
            })
        }
    }
    
    func topViewController() -> BaseViewController? {
        if let root: UINavigationController = self.window?.rootViewController as? UINavigationController {
            if root.viewControllers.count > 0 {
                if let base = root.viewControllers[0] as? BaseViewController {
                    return base
                }
            }
        }
        return nil
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

