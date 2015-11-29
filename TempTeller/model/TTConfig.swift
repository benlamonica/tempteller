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

public class TTConfig {
    
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
        }
    }
    var pushToken : String {
        didSet {
            settings.setValue(pushToken, forKey: "pushToken")
            settings.synchronize()
        }
    }
    var serverUrl : String {
        didSet {
            settings.setValue(serverUrl, forKey: "serverUrl")
            settings.synchronize()
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
        keychain = KeychainSwift()
        settings = NSUserDefaults.standardUserDefaults()
        subEndDate = settings.valueForKey("subEndDate") as? String ?? "NotSubscribed"
        uid = keychain.get("uid") ?? "-1"
        pushToken = settings.valueForKey("pushToken") as? String ?? "NotDefined"
        serverUrl = "\((settings.valueForKey("serverUrl") ?? "http://nix.local:8080") as! String)/\(uid)"
        rules = settings.valueForKey("rules") as? String ?? "[]"
        isTestEnv = isAPNSandbox() 
    }

    func isAPNSandbox() -> Bool {
        if let mobileProvisionURL = NSBundle.mainBundle().URLForResource("embedded", withExtension: "mobileprovision"),
        let mobileProvisionData = NSData(contentsOfURL: mobileProvisionURL),
        let mobileProvision = TCMobileProvision(data: mobileProvisionData) {
            if let entitlements = mobileProvision.dict["Entitlements"],
            let apsEnvironment = entitlements["aps-environment"] as? String
            where apsEnvironment == "development" {
                return true
            }
        }

        return false
    }    

    static let shared = TTConfig()
}
