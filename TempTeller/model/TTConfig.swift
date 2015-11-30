//
//  TempTellerConfig.swift
//  TempTeller
//
//  Created by Ben La Monica on 11/16/15.
//  Copyright © 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation
import KeychainSwift

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
    var server : String {
        didSet {
            settings.setValue(serverUrl, forKey: "server")
            settings.synchronize()
        }
    }
    
    var serverUrl : String {
        get {
            return "\(server)/\(uid)"
        }
    }
    
    var rules : String {
        didSet {
            settings.setValue(rules, forKey: "rules")
            settings.synchronize()
        }
    }
    
    
    init() {
        keychain = KeychainSwift()
        settings = NSUserDefaults.standardUserDefaults()
        subEndDate = settings.valueForKey("subEndDate") as? String ?? "NotSubscribed"
        uid = keychain.get("uid") ?? "-1"
        pushToken = settings.valueForKey("pushToken") as? String ?? "NotDefined"
        server = settings.valueForKey("server") as? String ?? "http://nix.local:8080/"
        rules = settings.valueForKey("rules") as? String ?? "[]"
    }
    
    static let shared = TTConfig()
}