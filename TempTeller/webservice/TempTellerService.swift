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
    func registerPushToken(pushToken: String) {
        var replaces : String? = nil
        if pushToken != config.pushToken {
            NSLog("device token differs from what we've registered in the past, notify server")
            replaces = config.pushToken
        }

        do {
            let priorUrl = replaces != nil ? "&priorPushToken=\(replaces!)" : ""
            let url = "\(config.serverUrl)/login?pushToken=\(pushToken)\(priorUrl)&timezone=\(NSTimeZone.defaultTimeZone().name)"
            NSLog("logging in: \(url)")
            
            let req = try HTTP.POST(url)
            
            req.start() { response in
                self.processAuthResult(response)
                self.config.pushToken = pushToken
            }
        } catch let error {
            NSLog("failed to create http request. \(error)")
        }
    }
    
    func restoreSubscriptionForDevice(deviceId : String, pushToken: String, receipt: String) {
        let url = "\(config.serverUrl)/restore"
        do {
            let req = try HTTP.POST(url, parameters: ["pushToken":pushToken, "deviceId":deviceId, "receipt":receipt])
            req.start() { response in
                self.processAuthResult(response)
            }
        } catch let err {
            NSLog("Unable to contact server due to \(err)")
        }
    }

    func processAuthResult(response: Response) {
        NSLog("response: \(response.text!)")
        let json = JSON(data: response.data)
        let serverUid = json["uid"].string ?? "-1"
        self.config.subEndDate = json["subEndDate"].string ?? "NotSubscribed"
        if serverUid != self.config.uid {
            self.config.uid = serverUid
        }
    }
    
    func addSubscriptionForDevice(deviceId : String, receiptPKCS7: String) {
        let url = "\(config.serverUrl)/subscribe"
        do {
            let req = try HTTP.POST(url, parameters: ["deviceId":deviceId, "receipt":receiptPKCS7])
            req.start() { response in
                self.processAuthResult(response)
            }
        } catch let err {
            NSLog("Unable to contact server due to \(err)")
        }
    }

}