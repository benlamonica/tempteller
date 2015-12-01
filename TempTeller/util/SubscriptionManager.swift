//
//  SubscriptionManager.swift
//  TempTeller
//
//  Created by Ben La Monica on 9/25/15.
//  Copyright © 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation
import StoreKit
import UIKit

protocol StatusNotifier {
    func setStatus(status : String)
    func fail(msg: String)
    func hideStatus()
    func updatePrices(prices: [String:SKProduct])
}
class SubscriptionManager: NSObject {
    var products : [String:SKProduct] = [:]
    var observers : [AnyObject] = []
    var config = TTConfig.shared
    var tt = TempTellerService()
    let status : StatusNotifier
    
    init(status: StatusNotifier) {
        self.status = status
        super.init()
        requestSubscriptionInfo(["1_Month","6_Month","12_Month"]) { (product : SKProduct) in
            do {
                objc_sync_enter(self.products)
                defer { objc_sync_exit(self.products) }
                self.products[product.productIdentifier] = product
            }
            status.updatePrices(self.products)
            NSLog("Received product \(product.productIdentifier), with price \(product.localizedPrice())")
        }
    }

    func addObserver(observer: NSObject) {
        objc_sync_enter(observers)
        defer { objc_sync_exit(observers) }
        observers.append(observer)
        NSLog("Observer %p added", observer)
    }
    
    func removeObserver(observer: NSObject) {
        objc_sync_enter(observers)
        defer { objc_sync_exit(observers) }
        let filtered = observers.filter {$0 as? NSObject != observer}
        observers.removeAll(keepCapacity: true)
        observers.appendContentsOf(filtered)
        NSLog("Observer %p removed", observer)
    }
    
    func subscribe(productKey : String, onCompletion : (receipts: [SKPaymentTransaction]) -> ()) {
        NSLog("subscribe to \(productKey)")
        requestSubscriptionInfo([productKey]) { (product : SKProduct) in
            self.status.setStatus("Subscribing for \(product.localizedTitle)")
            let purchase = SKPayment(product: product)
            let observer = TxnObserver(parent: self, processReceipt: onCompletion, payment: purchase)
            
            self.addObserver(observer)
            SKPaymentQueue.defaultQueue().addTransactionObserver(observer)
            
            NSLog("submitting %@ to purchase", product.productIdentifier)
            SKPaymentQueue.defaultQueue().addPayment(purchase)
        }
    }

    func restoreSubs(onCompletion : (receipts: [SKPaymentTransaction]) -> ()) {
        NSLog("restore subscriptions")
        status.setStatus("Restoring Subscriptions")
        let refreshReq = SKReceiptRefreshRequest()
        let observer = ReceiptReqDelegate(parent: self, processReceipts: onCompletion)
        addObserver(observer)
        
        refreshReq.delegate = observer
        refreshReq.start()
    }
    
    func requestSubscriptionInfo(productIds: Set<String>, onCompletion : (product : SKProduct) -> ()) {
        do {
            objc_sync_enter(products)
            defer { objc_sync_exit(products) }
            if (!products.isEmpty) {
                for product in products.values {
                    if productIds.contains(product.productIdentifier) {
                        onCompletion(product: product)
                    }
                }
                return
            }
        }
        
        let skreq = SKProductsRequest(productIdentifiers: productIds)
        let observer = ProductObserver(parent: self, onProductRcvd: onCompletion)
        addObserver(observer)
        skreq.delegate = observer
        skreq.start()
    }
    
    class TxnObserver : NSObject, SKPaymentTransactionObserver {
        unowned let parent : SubscriptionManager
        let processReceipt : (receipts: [SKPaymentTransaction]) -> ()
        var payment : SKPayment?
        
        init(parent: SubscriptionManager, processReceipt: (receipts: [SKPaymentTransaction]) -> (), payment: SKPayment?) {
            self.payment = payment
            self.parent = parent
            self.processReceipt = processReceipt
        }
        
        convenience init(parent: SubscriptionManager, processReceipt: (receipts: [SKPaymentTransaction]) -> ()) {
            self.init(parent: parent, processReceipt: processReceipt, payment: nil)
        }
        
        @objc func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions:[SKPaymentTransaction]) {
            NSLog("Received \(transactions.count) transactions")
            var removeObserver = false
            var receipts : [SKPaymentTransaction] = []
            for txn in transactions {
                NSLog("Got a transaction: \(txn.toString())")
                if payment == nil || (payment != nil && payment == txn.payment) {
                    switch txn.transactionState {
                    case .Restored:
                        removeObserver = true
                        NSLog("Restored Txn: \(txn)")
                        receipts.append(txn.originalTransaction!)
                        queue.finishTransaction(txn)
                    case .Purchased:
                        removeObserver = true
                        receipts.append(txn)
                        queue.finishTransaction(txn)
                    case .Failed:
                        //removeObserver = true
                        //queue.finishTransaction(txn)
                        NSLog("TXN failed %@", txn.error ?? "No error received.")
                    default:
                        break
                    }
                }
            }
            
            if removeObserver {
                queue.removeTransactionObserver(self)
                parent.removeObserver(self)
            }

            if !receipts.isEmpty {
                // we actually don't care about the receipts coming into this method, as it can be spoofed by people who are hacking our app. Just process the receipt from the app store which is cryptographically signed and more difficult to spoof. Plus, this will send the receipt to the server, which is how it validates everything is fine and recalculates the subEndDate.
                parent.validateReceipt()
            }
        }
        
        // Sent when an error is encountered while adding transactions from the user's purchase history back to the queue.
        func paymentQueue(queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: NSError) {
            NSLog("Error while requesting restore: %@", error)
            queue.removeTransactionObserver(self)
            parent.removeObserver(self)
        }
        
        // Sent when all transactions from the user's purchase history have successfully been added back to the queue.
        func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
            NSLog("Finished restoring purcahses")
            queue.removeTransactionObserver(self)
            parent.removeObserver(self)
        }

    }
    
    class ProductObserver : NSObject, SKProductsRequestDelegate {
        unowned let parent : SubscriptionManager
        
        let onProductRcvd : (product: SKProduct) -> ()
        init(parent: SubscriptionManager, onProductRcvd : (product: SKProduct) -> ()) {
            self.onProductRcvd = onProductRcvd
            self.parent = parent
        }
        func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
            if response.products.count > 0 {
                for product in response.products {
                    onProductRcvd(product: product)
                }
            } else {
                NSLog("Received response, but nothing was returned. %@", response)
            }
            parent.removeObserver(self)
        }
    }

    func validateReceipt(isRestore : Bool = false) {
        status.setStatus("Verifying Purchase")
        guard let receiptUrl = NSBundle.mainBundle().appStoreReceiptURL else {
            status.fail("Unable to restore subscriptions. Make sure you are connected to the internet.")
            return
        }
        
        guard let receiptPKCS7 = NSMutableData(contentsOfURL: receiptUrl) else {
            NSLog("Can't read pkcs#7 receipt data from: \(receiptUrl)")
            return
        }
        
        OPENSSL_add_all_algorithms_noconf()
        
        let receiptBuf = BIO_new_mem_buf(receiptPKCS7.mutableBytes, Int32(receiptPKCS7.length))
        defer { BIO_free(receiptBuf) }
        
        let appleRootCertBuf = BIO_new_mem_buf(SubscriptionManager.AppleRootX509.mutableBytes, Int32(SubscriptionManager.AppleRootX509.length))
        defer { BIO_free(appleRootCertBuf) }
        
        let receipt = d2i_PKCS7_bio(receiptBuf, nil)
        defer { PKCS7_free(receipt) }
        
        let rootCert = d2i_X509_bio(appleRootCertBuf, nil)
        defer { X509_free(rootCert) }
        
        let certStore = X509_STORE_new()
        defer { X509_STORE_free(certStore) }
        
        X509_STORE_add_cert(certStore, rootCert)
        
        let receiptPayload = BIO_new(BIO_s_mem())
        defer { BIO_free(receiptPayload) }
        
        let isSigValid = PKCS7_verify(receipt, nil, certStore, nil, receiptPayload, 0) == 1
        
        NSLog("Receipt is %@", isSigValid ? "valid" : "invalid")
        
        if isSigValid {
            guard let deviceId = UIDevice.currentDevice().identifierForVendor else {
                NSLog("Unable to get the UUID from the device.")
                return
            }
            status.setStatus("Recording Purchase")
            if isRestore {
                tt.restoreSubscriptionForDevice(deviceId.UUIDString, pushToken: config.pushToken, receipt: receiptPKCS7.base64EncodedStringWithOptions([])) { (success: Bool, msg: String) in
                    if (!success) {
                        self.status.fail(msg)
                    } else {
                        self.status.setStatus("Success!")
                        self.status.hideStatus()
                    }
                }
            } else {
                tt.addSubscriptionForDevice(deviceId.UUIDString, receiptPKCS7: receiptPKCS7.base64EncodedStringWithOptions([])) { (success: Bool, msg: String) in
                    if (!success) {
                        self.status.fail(msg)
                    } else {
                        self.status.setStatus("Success!")
                        self.status.hideStatus()
                    }
                }
            }

        }
    }
    
    class ReceiptReqDelegate : NSObject, SKRequestDelegate {
        unowned let parent : SubscriptionManager
        let txnObserver : TxnObserver
        init(parent: SubscriptionManager, processReceipts: (receipts: [SKPaymentTransaction]) -> ()) {
            self.parent = parent
            txnObserver = TxnObserver(parent: parent, processReceipt: processReceipts)
            
        }
        func requestDidFinish(request: SKRequest) {
            parent.removeObserver(self)
            parent.validateReceipt(true)
        }
    }

    
    static let AppleRootX509 = NSMutableData(base64EncodedString: "MIIEuzCCA6OgAwIBAgIBAjANBgkqhkiG9w0BAQUFADBiMQswCQYDVQQGEwJVUzETMBEGA1UEChMKQXBwbGUgSW5jLjEmMCQGA1UECxMdQXBwbGUgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkxFjAUBgNVBAMTDUFwcGxlIFJvb3QgQ0EwHhcNMDYwNDI1MjE0MDM2WhcNMzUwMjA5MjE0MDM2WjBiMQswCQYDVQQGEwJVUzETMBEGA1UEChMKQXBwbGUgSW5jLjEmMCQGA1UECxMdQXBwbGUgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkxFjAUBgNVBAMTDUFwcGxlIFJvb3QgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDkkakJH5HbHkdQ6wXtXnmELes2oldMVeyLGYne+Uts9QerIjAC6Bg++FAJ039BqJj50cpmnCRrEdCju+QbKsMflZ56DKRHi1vUFjczy8QPTc4UadHJGXL1XQ7Vf1+b8iUDulWPTV0N8WQ1IxVLFVkds5T39pyez1C6wVhQZ48ItCD3y6wsIG9wtj8BMIy3Q88PnT3zK0koGsj+zrW5DtleHNbLPbU6rfQPDgCSC7EhFi501TwN22IWq6NxkkdTVcGvL0Gz+PvjcM3mo0xFfh9Ma1CWQYnEdGILEINBhzOKgbEwWOxaBDKMaLOPHd5lc/9nXmW8Sdh2nzMUZaF3lMktAgMBAAGjggF6MIIBdjAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQUK9BpR5R2Cf70a40uQKb3R01/CF4wHwYDVR0jBBgwFoAUK9BpR5R2Cf70a40uQKb3R01/CF4wggERBgNVHSAEggEIMIIBBDCCAQAGCSqGSIb3Y2QFATCB8jAqBggrBgEFBQcCARYeaHR0cHM6Ly93d3cuYXBwbGUuY29tL2FwcGxlY2EvMIHDBggrBgEFBQcCAjCBthqBs1JlbGlhbmNlIG9uIHRoaXMgY2VydGlmaWNhdGUgYnkgYW55IHBhcnR5IGFzc3VtZXMgYWNjZXB0YW5jZSBvZiB0aGUgdGhlbiBhcHBsaWNhYmxlIHN0YW5kYXJkIHRlcm1zIGFuZCBjb25kaXRpb25zIG9mIHVzZSwgY2VydGlmaWNhdGUgcG9saWN5IGFuZCBjZXJ0aWZpY2F0aW9uIHByYWN0aWNlIHN0YXRlbWVudHMuMA0GCSqGSIb3DQEBBQUAA4IBAQBcNplMLXi37Yyb3PN3m/J20ncwT8EfhYOFG5k9RzfyqZtAjizUsZAS2L70c5vu0mQPy3lPNNiiPvl4/2vIB+x9OYOLUyDTOMSxv5pPCmv/K/xZpwUJfBdAVhEedNO3iyM7R6PVbyTi69G3cN8PReEnyvFteO3ntRcXqNx+IjXKJdXZD9Zr1KIkIxH3oayPc4FgxhtbCS+SsvhESPBgOJ4V9T0mZyCKM2r3DYLP3uujL/lTaltkwGMzd/c6ByxW69oPIQ7aunMZT7XZNn/Bh1XZp5m5MkL72NVxnn6hUrcbvZNCJBIqxw8dtk2cXmPIS4AXUKqK1drk/NAJBzewdXUh", options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!
}
