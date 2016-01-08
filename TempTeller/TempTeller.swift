//
//  AppDelegate.swift
//  TempTeller
//
//  Created by Ben La Monica on 5/19/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import UIKit
import KeychainSwift
import SwiftHTTP
import SwiftyJSON
import XCGLogger


@UIApplicationMain
class TempTeller: UIResponder, UIApplicationDelegate {

    let log = XCGLogger.defaultInstance()
    var window: UIWindow?
    var config = TTConfig.shared
    let tt = TempTellerService()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        log.setup(config.isTestEnv ? .Debug : .Info, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true)
        log.info("Application running in \(config.isTestEnv ? "TEST" : "PROD") environment")
        // register the device to make sure it connects to the APN..The user will not be prompted for permission at this time. Request actual remote notification types after the user creates the first rule. see https://thatthinginswift.com/remote-notifications/
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func scheduleHeartbeatLocalNotification(userInfo: [NSObject : AnyObject]) {
        if userInfo["type"] as? String == "heartbeat" {
            let prevNotifications = UIApplication.sharedApplication().scheduledLocalNotifications!.filter {
                    return $0.alertBody! =~ "Haven't heard a heartbeat since"
                }
        
            for notification in prevNotifications {
                UIApplication.sharedApplication().cancelLocalNotification(notification)
            }
            
            let hbNotifier = UILocalNotification()
            hbNotifier.alertTitle = "Missed Heartbeat"
            hbNotifier.alertBody = "Haven't heard a heartbeat since \(NSDate())"
            hbNotifier.fireDate = NSDate(timeIntervalSinceNow: 15.0 * 60)
            hbNotifier.userInfo = userInfo
            UIApplication.sharedApplication().scheduleLocalNotification(hbNotifier)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo:  [NSObject : AnyObject]) {
        scheduleHeartbeatLocalNotification(userInfo)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let token = deviceToken.base64EncodedStringWithOptions([])
        log.info("registered for remote notifications: \(token)")
        tt.registerPushToken(token)
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        log.info("failed to register for notifications \(error)")
        tt.registerPushToken("FailedPushToken")
        // TODO when will this happen? When network is down? When push notifications have been denied? Find out if we need to notify the user that the app is basically useless without push notifications
    }
}

