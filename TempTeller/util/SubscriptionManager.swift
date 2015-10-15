//
//  SubscriptionManager.swift
//  TempTeller
//
//  Created by Ben La Monica on 9/25/15.
//  Copyright © 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation
import StoreKit

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
        let observer = TxnObserver(parent: self, processReceipt: onCompletion)
        addObserver(observer)
        SKPaymentQueue.defaultQueue().addTransactionObserver(observer)
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
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
}
