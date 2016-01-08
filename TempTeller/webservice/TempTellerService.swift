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
    let sslPin = HTTPSecurity(certs: [SSLCert(data: TempTellerService.SERVER_CERT), SSLCert(data: TempTellerService.CA_CERT)], usePublicKeys: false)
    
    init() {
        if config.keychain.getData(kSecClassCertificate as String) == nil {
            config.keychain.set(TempTellerService.CA_CERT, forKey: kSecClassCertificate as String)
            NSLog("added CA to keychain: \(config.keychain.lastResultCode)")
        }
    }
    
    func registerPushToken(pushToken: String, priorPushToken: String = TTConfig.shared.pushToken) {
        var priorUrl = ""
        if pushToken != priorPushToken && priorPushToken != "NotDefined" {
            log.info("device token differs from what we've registered in the past, notify server")
            priorUrl = "&priorPushToken=\(priorPushToken)"
        }

        do {
            let url = "\(config.serverUrl)/login?pushToken=\(pushToken)\(priorUrl)&timezone=\(NSTimeZone.defaultTimeZone().name.escaped!)"
            log.debug("Login: \(url)")
            
            let req = try HTTP.POST(url)
            req.security = sslPin
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
            req.security = sslPin
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
            req.security = sslPin
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
            req.security = sslPin
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
            req.security = sslPin
            req.start() { response in
            }
        } catch let err {
            log.warning("Unable to contact server due to \(err)")
        }
    }
    
    func deleteRule(ruleId: String, onFinish: (success: Bool, msg: String) -> ()) {
        log.info("Deleting rule \(ruleId) on server")
        let url = "\(config.serverUrl)/rule/\(ruleId)/delete?pushToken=\(config.pushToken.escaped!)"
        log.debug("POST \(url)")
        do {
            let req = try HTTP.POST(url)
            req.security = sslPin
            req.start() { response in
                onFinish(success: response.text=="OK", msg: response.text ?? "")
            }
        } catch let err {
            log.warning("Unable to contact server due to \(err)")
            onFinish(success: false, msg:"Unable to contact server, please delete again later.")
        }
    }
    
    static let SERVER_CERT = NSMutableData(base64EncodedString:"MIIDozCCAougAwIBAgIJAL2OdPoa/y63MA0GCSqGSIb3DQEBCwUAMIGKMQswCQYDVQQGEwJVUzERMA8GA1UECBMISWxsaW5vaXMxDzANBgNVBAcTBkF1cm9yYTEdMBsGA1UEChMUQmVuamFtaW4gQSBMYSBNb25pY2ExFTATBgNVBAMTDFBvam8gUm9vdCBDQTEhMB8GCSqGSIb3DQEJARYScG9qb2FwcHNAZ21haWwuY29tMB4XDTE2MDEwNzIzMzMwNloXDTI2MDEwNDIzMzMwNlowRDELMAkGA1UEBhMCVVMxCzAJBgNVBAgTAklMMRMwEQYDVQQKEwpUZW1wVGVsbGVyMRMwEQYDVQQDEwp0dC5wb2pvLnVzMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA4NbowcRAqw+0I2WWzvKLUDgRAbraflQoiMr9Yz8ZjAVc/3Ly2SeyNrMPK9b4S4HsLWVNCS11Iwx9STyKbBpFzmGbEfGx/uXaF5ZG59yu7HpTsGflnN1WWWnMP0agsNnoFxiBFU/08iKEi8LtojtNjyaHA9pg3Fbiccd1DTjxo42N3ycQ7g2GrUZBsKjURnASQ8wlOZhk7yMNxLbzZ9vom7PqjEVkbf+OxaHY5aLvBa5o8C4u+lLlxb2Jlq869AAiCrKMq3dZyVrwvUOIe33+QUUqcqHfO3UYwVwptz8/ha+VLieNH93CGE6EZAmmXQjgAfh2s1gB8o4u/iH7UlM+TwIDAQABo1EwTzAJBgNVHRMEAjAAMAsGA1UdDwQEAwIF4DA1BgNVHREELjAsgg90dC10ZXN0LnBvam8udXOCDnR0LWRldi5wb2pvLnVzggluaXgubG9jYWwwDQYJKoZIhvcNAQELBQADggEBAC1jDbdnykb4B6wdvuUVOC55jiegG97CR0gypI0kZSQereO5O5yvMyrxeW+xdTP7EuImk10vEDujaKv/X0X0yffaAxVTNJa0Vqef6iBdRSix5bbY9dwRUYtENUSzd6afupBbFUXRU9xJGP1bapUSUSI4XWV/Nq9UJuzGfXhFpcePeNHa/Oa+aan/CdFpYjGIgb+PKMg46LrDSnjiRQAHiqfSE+3WIfwqNjrkNd4V/gIcbjp3kj98E3olo6MFtmwdwmopbN7uEUCYPIOOlgQZCSccNDUEHvU1VVAXpgd3uKOW6bYrrTwJa3RXZlhB4q7+lDm57YIa8IVeej2xRVb/YSc=", options: .IgnoreUnknownCharacters)!
    
    static let CA_CERT = NSMutableData(base64EncodedString: "MIIEjDCCA3SgAwIBAgIJAN69amr2ik3VMA0GCSqGSIb3DQEBCwUAMIGKMQswCQYDVQQGEwJVUzERMA8GA1UECBMISWxsaW5vaXMxDzANBgNVBAcTBkF1cm9yYTEdMBsGA1UEChMUQmVuamFtaW4gQSBMYSBNb25pY2ExFTATBgNVBAMTDFBvam8gUm9vdCBDQTEhMB8GCSqGSIb3DQEJARYScG9qb2FwcHNAZ21haWwuY29tMB4XDTE1MTIxNzE2NTcyMloXDTM1MTIxMjE2NTcyMlowgYoxCzAJBgNVBAYTAlVTMREwDwYDVQQIEwhJbGxpbm9pczEPMA0GA1UEBxMGQXVyb3JhMR0wGwYDVQQKExRCZW5qYW1pbiBBIExhIE1vbmljYTEVMBMGA1UEAxMMUG9qbyBSb290IENBMSEwHwYJKoZIhvcNAQkBFhJwb2pvYXBwc0BnbWFpbC5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCmaxeoM3p5Lft4i5WpGt8QVe5nwn+IN1hrRpXDp4McRhSXGSr74QwkE58sbk2qDGIXYb1bni0G3rPDWF57WiFB4YzQz9GbaoqArZ7X7faDz5yUOi8S34ZxPtqR6m0hc6cKIz5NOwcmW9uoM+xYqDR7oNRBsXBHuV+eaiz2ZZsga69MTBG0eb6i9ovf3sjxnNALyT+lr0v/NwZsG3hTErc2dK8LCq8nWTmIf3nloQmzBLEh4beOCH4jx3NFMdY/LQQUe61cXLOLaxRtcrFnP2t/qXvOoTlLNQAMyErwyK25JarKlgi35CyglUzdsSMEY8roFaake3NmnQSO+dpXW235AgMBAAGjgfIwge8wHQYDVR0OBBYEFJdedgEJKQgZr7xOIa2sw4IGOPkhMIG/BgNVHSMEgbcwgbSAFJdedgEJKQgZr7xOIa2sw4IGOPkhoYGQpIGNMIGKMQswCQYDVQQGEwJVUzERMA8GA1UECBMISWxsaW5vaXMxDzANBgNVBAcTBkF1cm9yYTEdMBsGA1UEChMUQmVuamFtaW4gQSBMYSBNb25pY2ExFTATBgNVBAMTDFBvam8gUm9vdCBDQTEhMB8GCSqGSIb3DQEJARYScG9qb2FwcHNAZ21haWwuY29tggkA3r1qavaKTdUwDAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAQEAFuVeXXLf8U56tA+mrv0wUi3V7/1cRnnGBXiy6dSRPFrgdwXyWrdLK8+IwkGZSGmanXELviNZkI181OUbL4zIJ9rCoQkst62a1H+3zd2SaCNqf7mWVKvEgfOeeJ51FE4HOnZk2LqTiprH31PVxUf+IWdU2ULvFak3xGQRb5/CM2dnPcvIEBuWEGDK/zDbpzQrGopG3W5A6jB6SIDUAlePFsFIXj3jl5fBuPvkuLUgZwKGd5lt1JX9a37YxMD4USJfHTISdLuiHHxqg0pi0frmZ9jpksl7PeML32BRyEG7j1i+v0X5xvxieQohyZ7Aclgc28VdezIFGn33RNyP4IQfqg==", options: .IgnoreUnknownCharacters)!

}