//
//  TempTellerConfig.swift
//  TempTeller
//
//  Created by Ben La Monica on 11/16/15.
//  Copyright © 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation
import KeychainSwift
import TCMobileProvision
import XCGLogger
public class TTConfig {
    let log = XCGLogger.defaultInstance()
    let keychain : KeychainSwift
    let settings : NSUserDefaults
    var subEndDate : String {
        didSet {
            settings.setValue(subEndDate, forKey: "subEndDate")
            settings.synchronize()
        }
    }
    var uid : String {
        didSet {
            keychain.set(uid, forKey: "uid")
            log.debug("keychain status code: \(keychain.lastResultCode)")
        }
    }
    var pushToken : String {
        didSet {
            settings.setValue(pushToken, forKey: "pushToken")
            settings.synchronize()
        }
    }
    var server : String {
        didSet {
            settings.setValue(server, forKey: "server")
            settings.synchronize()
        }
    }
    
    var serverUrl : String {
        get {
            return "\(server)"
        }
    }
    
    var rules : String {
        didSet {
            settings.setValue(rules, forKey: "rules")
            settings.synchronize()
        }
    }
   
    let isTestEnv : Bool 
    
    init() {
        let testEnv = TTConfig.isAPNSandbox()
        isTestEnv = testEnv
        keychain = KeychainSwift(keyPrefix: isTestEnv ? "testing" : "")
        settings = NSUserDefaults.standardUserDefaults()
        subEndDate = settings.valueForKey("subEndDate") as? String ?? "NotSubscribed"
        uid = keychain.get("uid") ?? "-1"
        pushToken = settings.valueForKey("pushToken") as? String ?? "NotDefined"
        server = settings.valueForKey("server") as? String ?? (testEnv ? "https://tt-dev.pojo.us:8443" : "https://tt.pojo.us")
        rules = settings.valueForKey("rules") as? String ?? "[]"
    }

    private class func isAPNSandbox() -> Bool {
        if let mobileProvisionURL = NSBundle.mainBundle().URLForResource("embedded", withExtension: "mobileprovision"),
        let mobileProvisionData = NSData(contentsOfURL: mobileProvisionURL),
        let mobileProvision = TCMobileProvision(data: mobileProvisionData) {
            if let entitlements = mobileProvision.dict["Entitlements"],
            let apsEnvironment = entitlements["aps-environment"] as? String
            where apsEnvironment != "development" {
                return false
            }
        }

        return true
    }    

    static let shared = TTConfig()
}
