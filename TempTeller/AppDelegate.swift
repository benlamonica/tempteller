//
//  AppDelegate.swift
//  TempTeller
//
//  Created by Ben La Monica on 5/19/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import UIKit

let DEVICE_TOKEN_KEY = "deviceToken"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // register the device to make sure it connects to the APN..The user will not be prompted for permission at this time. Request actual remote notification types after the user creates the first rule. see https://thatthinginswift.com/remote-notifications/
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func scheduleHeartbeatLocalNotification(userInfo: [NSObject : AnyObject]) {
        if userInfo["type"] as? String == "heartbeat" {
            let prevNotifications = UIApplication.sharedApplication().scheduledLocalNotifications.filter {
                if let notif = $0 as? UILocalNotification {
                    return notif.alertTitle == "Missed Heartbeat"
                } else {
                    return false
                }
            }
        
            for notification in prevNotifications {
                if let localNotif = notification as? UILocalNotification {
                    UIApplication.sharedApplication().cancelLocalNotification(localNotif)
                }
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
        let token = deviceToken.base64EncodedStringWithOptions(nil)
        NSLog("registered for remote notifications: \(token)")
        
        let settings = NSUserDefaults.standardUserDefaults()
        if let existingDeviceToken = settings.valueForKey(DEVICE_TOKEN_KEY) as? String {
            if token != existingDeviceToken {
                NSLog("device token differs from what we've registered in the past, notify server")
                register(token, replaces: existingDeviceToken)
            }
        } else {
            NSLog("first time this device has been registered")
            register(token)
        }
    }
    
    func register(deviceToken: String, replaces: String? = nil) {
        // TODO - notify the server
        // then run the below commands in a callback after successfully notifying the server
        // POST https://host/register-device?token=ABCD&replaces=EFGHI
        func callback() {
            let settings = NSUserDefaults.standardUserDefaults()
            settings.setValue(deviceToken, forKey:DEVICE_TOKEN_KEY)
            settings.synchronize()
        }
        callback()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        NSLog("failed to register for notifications \(error)")
        // TODO? when will this happen? When network is down? When push notifications have been denied? Find out if we need to notify the user that the app is basically useless without push notifications
    }
}

