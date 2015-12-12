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
import XCGLogger

class TempTellerService {
    let log = XCGLogger.defaultInstance()
    var config = TTConfig.shared
    func registerPushToken(pushToken: String, priorPushToken: String? = TTConfig.shared.pushToken) {
        var priorUrl = ""
        if pushToken != priorPushToken {
            log.info("device token differs from what we've registered in the past, notify server")
            priorUrl = "&priorPushToken=\(priorPushToken)"
        }

        do {
            let url = "\(config.serverUrl)/login?pushToken=\(pushToken)\(priorUrl)&timezone=\(NSTimeZone.defaultTimeZone().name.escaped!)"
            log.debug("Login: \(url)")
            
            let req = try HTTP.POST(url)
            
            req.start() { response in
                self.processAuthResult(response) { (success: Bool, msg: String) in
                    if success {
                        self.log.debug("device token changed to \(pushToken)")
                        self.config.pushToken = pushToken
                    } else {
                        self.log.warning("Unable to log in, may cause problems in the future.")
                    }
                }
            }
        } catch let error {
            log.warning("failed to create http request. \(error)")
        }
    }
    
    func restoreSubscriptionForDevice(deviceId : String, pushToken: String, receipt: String, onFinish: (success: Bool, msg: String) -> ()) {
        log.info("Sending restored subscription receipt to server.")
        let url = "\(config.serverUrl)/restore"
        do {
            let req = try HTTP.POST(url, parameters: ["pushToken":pushToken, "deviceId":deviceId, "receipt":receipt])
            req.start() { response in
                self.processAuthResult(response, onFinish: onFinish)
            }
        } catch let err {
            log.warning("Unable to contact server due to \(err)")
        }
    }

    func processAuthResult(response: Response, onFinish: (success: Bool, msg: String) -> ()) {
        log.debug("response: \(response.text!)")
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
        } else {
            log.warning("Response code was \(response.statusCode)")
        }
        
        onFinish(success: wasSuccessful, msg: msg)
    }
    
    func addSubscriptionForDevice(deviceId : String, receiptPKCS7: String, onFinish: (success: Bool, msg: String) -> ()) {
        log.info("Sending subscription receipt to server.")
        let url = "\(config.serverUrl)/subscribe"
        do {
            let req = try HTTP.POST(url, parameters: ["deviceId":deviceId, "receipt":receiptPKCS7])
            req.start() { response in
                self.processAuthResult(response, onFinish: onFinish)
            }
        } catch let err {
            log.warning("Unable to contact server due to \(err)")
            onFinish(success: false, msg:"Unable to contact server due to \(err)")
        }
    }
    
    func saveRules(rules: [[String:AnyObject]], onFinish: (success: Bool, msg: String) -> ()) {
        log.info("Sending \(rules.count) rules to server.")
        let url = "\(config.serverUrl)/rules?pushToken=\(config.pushToken.escaped!)&tz=\(NSTimeZone.defaultTimeZone().name.escaped!)"
        log.debug("POST \(url)")
        do {
            let req = try HTTP.POST(url, parameters:rules, requestSerializer: JSONParameterSerializer())
            req.start() { response in
                onFinish(success: response.text=="OK", msg: response.text ?? "")
            }
        } catch let err {
            log.warning("Unable to contact server due to \(err)")
            onFinish(success: false, msg:"Unable to contact server due to \(err)")
        }
    }
    
    func saveRule(rule: Rule) {
        log.info("Sending rule \(rule.uuid) to server")
        let url = "\(config.serverUrl)/rule/\(rule.uuid)?pushToken=\(config.pushToken.escaped!)&tz=\(NSTimeZone.defaultTimeZone().name.escaped!)"
        log.debug("POST \(url)")
        do {
            let req = try HTTP.POST(url, parameters:rule.toDict(), requestSerializer: JSONParameterSerializer())
            req.start() { response in
            }
        } catch let err {
            log.warning("Unable to contact server due to \(err)")
        }
    }
    
    func deleteRule(ruleId: String, onFinish: (success: Bool, msg: String) -> ()) {
        log.info("Deleting rule \(ruleId) on server")
        let url = "\(config.serverUrl)/\(config.pushToken)/rule/\(ruleId)/delete"
        log.debug("POST \(url)")
        do {
            let req = try HTTP.POST(url)
            req.start() { response in
                onFinish(success: response.text=="OK", msg: response.text ?? "")
            }
        } catch let err {
            log.warning("Unable to contact server due to \(err)")
            onFinish(success: false, msg:"Unable to contact server due to \(err)")
        }
    }

}