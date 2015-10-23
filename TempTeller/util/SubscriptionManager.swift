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

class SubscriptionManager : NSObject {
    var products : [String:SKProduct] = [:]
    var observers : [AnyObject] = []
    override init() {
        super.init()
        requestSubscriptionInfo(["1_Month","6_Month","12_Month"]) { (product : SKProduct) in
            do {
                objc_sync_enter(self.products)
                defer { objc_sync_exit(self.products) }
                self.products[product.productIdentifier] = product
            }
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
        let refreshReq = SKReceiptRefreshRequest()
        let observer = ReceiptReqDelegate(parent: self, processReceipts: onCompletion)
        addObserver(observer)
        refreshReq.delegate = observer

//        SKPaymentQueue.defaultQueue().addTransactionObserver(observer)
//        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
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
                processReceipt(receipts: receipts)
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

    class ReceiptReqDelegate : NSObject, SKRequestDelegate {
        unowned let parent : SubscriptionManager
        let txnObserver : TxnObserver
        init(parent: SubscriptionManager, processReceipts: (receipts: [SKPaymentTransaction]) -> ()) {
            self.parent = parent
            txnObserver = TxnObserver(parent: parent, processReceipt: processReceipts)
            
        }
        func requestDidFinish(request: SKRequest) {
            parent.removeObserver(self)
            guard let receiptUrl = NSBundle().appStoreReceiptURL else {
                let av = UIAlertView(title: "Problem", message: "Unable to restore subscriptions. Make sure you are connected to the internet.", delegate: nil, cancelButtonTitle: "Dismiss")
                av.show()
                return
            }
            
            guard let receiptPKCS7 = NSMutableData(contentsOfURL: receiptUrl) else {
                NSLog("Can't read pkcs#7 receipt data from: \(receiptUrl)")
                return
            }

            OPENSSL_add_all_algorithms_noconf()
            
            let appleRootX509 = NSMutableData(base64EncodedString: "apple root cert", options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!
            
            let receiptBuf = BIO_new_mem_buf(receiptPKCS7.mutableBytes, Int32(receiptPKCS7.length))
            defer { BIO_free(receiptBuf) }
            
            let appleRootCertBuf = BIO_new_mem_buf(appleRootX509.mutableBytes, Int32(appleRootX509.length))
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
            
            let isReceiptValid = PKCS7_verify(receipt, nil, certStore, nil, receiptPayload, 0) == 1
            
            NSLog("Receipt is %@", isReceiptValid ? "valid" : "invalid")
        }
    }

}
