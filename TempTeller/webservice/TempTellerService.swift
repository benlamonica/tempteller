//
//  TempTellerService.swift
//  TempTeller
//
//  Created by Ben La Monica on 11/19/15.
//  Copyright © 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation
import SwiftHTTP
import SwiftyJSON

class TempTellerService {
    var config = TTConfig.shared
    func registerPushToken(pushToken: String, priorPushToken: String? = TTConfig.shared.pushToken) {
        var priorUrl = ""
        if pushToken != priorPushToken {
            NSLog("device token differs from what we've registered in the past, notify server")
            priorUrl = "&priorPushToken=\(priorPushToken)"
        }

        do {
            let url = "\(config.serverUrl)/login?pushToken=\(pushToken)\(priorUrl)&timezone=\(NSTimeZone.defaultTimeZone().name)"
            NSLog("Changing Device Token: \(url)")
            
            let req = try HTTP.POST(url)
            
            req.start() { response in
                self.processAuthResult(response) { (success: Bool, msg: String) in
                    if success {
                        NSLog("device token changed to %@", pushToken)
                        self.config.pushToken = pushToken
                    }
                }
            }
        } catch let error {
            NSLog("failed to create http request. \(error)")
        }
    }
    
    func restoreSubscriptionForDevice(deviceId : String, pushToken: String, receipt: String, onFinish: (success: Bool, msg: String) -> ()) {
        let url = "\(config.serverUrl)/restore"
        do {
            let req = try HTTP.POST(url, parameters: ["pushToken":pushToken, "deviceId":deviceId, "receipt":receipt])
            req.start() { response in
                self.processAuthResult(response, onFinish: onFinish)
            }
        } catch let err {
            NSLog("Unable to contact server due to \(err)")
        }
    }

    func processAuthResult(response: Response, onFinish: (success: Bool, msg: String) -> ()) {
        NSLog("response: \(response.text!)")
        var msg = "Unable to Connect"
        var wasSuccessful = false
        if response.statusCode == 200 {
            let json = JSON(data: response.data)
            let serverUid = json["uid"].string ?? "-1"
            self.config.subEndDate = json["subEndDate"].string ?? "NotSubscribed"
            if serverUid != self.config.uid {
                self.config.uid = serverUid
            }
            msg = json["msg"].string ?? ""
            wasSuccessful = json["msg"].string == "OK"
        }
        
        onFinish(success: wasSuccessful, msg: msg)
    }
    
    func addSubscriptionForDevice(deviceId : String, receiptPKCS7: String, onFinish: (success: Bool, msg: String) -> ()) {
        let url = "\(config.serverUrl)/subscribe"
        do {
            let req = try HTTP.POST(url, parameters: ["deviceId":deviceId, "receipt":receiptPKCS7])
            req.start() { response in
                self.processAuthResult(response, onFinish: onFinish)
            }
        } catch let err {
            NSLog("Unable to contact server due to \(err)")
            onFinish(success: false, msg:"Unable to contact server due to \(err)")
        }
    }
    
    func saveRules(rules: [[String:AnyObject]], onFinish: (success: Bool, msg: String) -> ()) {
        let url = "\(config.serverUrl)/rules?pushToken=\(config.pushToken.escaped!)&tz=\(NSTimeZone.defaultTimeZone().name.escaped!)"
        NSLog("POST %@", url)
        do {
            let req = try HTTP.POST(url, parameters:rules, requestSerializer: JSONParameterSerializer())
            req.start() { response in
                onFinish(success: response.text=="OK", msg: response.text ?? "")
            }
        } catch let err {
            NSLog("Unable to contact server due to \(err)")
            onFinish(success: false, msg:"Unable to contact server due to \(err)")
        }
    }
    
    func saveRule(rule: Rule) {
        let url = "\(config.serverUrl)/rule?pushToken=\(config.pushToken.escaped!)&tz=\(NSTimeZone.defaultTimeZone().name.escaped!)"
        NSLog("POST %@", url)
        do {
            let req = try HTTP.POST(url, parameters:rule.toDict(), requestSerializer: JSONParameterSerializer())
            req.start() { response in
            }
        } catch let err {
            NSLog("Unable to contact server due to \(err)")
        }
    }
    
    func deleteRule(ruleId: String, onFinish: (success: Bool, msg: String) -> ()) {
        let url = "\(config.serverUrl)/\(config.pushToken)/rule/\(ruleId)/delete"
        NSLog("POST \(url)")
        do {
            let req = try HTTP.POST(url)
            req.start() { response in
                onFinish(success: response.text=="OK", msg: response.text ?? "")
            }
        } catch let err {
            NSLog("Unable to contact server due to \(err)")
            onFinish(success: false, msg:"Unable to contact server due to \(err)")
        }
    }

}