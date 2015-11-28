//
//  SKProductExtensions.swift
//  TempTeller
//
//  Created by Ben La Monica on 9/25/15.
//  Copyright © 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation
import StoreKit

extension SKProduct {
    func localizedPrice() -> String {
        let nf = NSNumberFormatter()
        nf.formatterBehavior = NSNumberFormatterBehavior.Behavior10_4
        nf.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        nf.locale = self.priceLocale
        return nf.stringFromNumber(self.price) ?? "..."
    }    
}

extension SKPaymentTransactionState : CustomStringConvertible {
    public var description : String {
        switch self {
            // Use Internationalization, as appropriate.
        case .Failed: return "Failed"
        case .Restored: return "Restored"
        case .Purchased: return "Purchased"
        case .Deferred: return "Deferred"
        case .Purchasing: return "Purchasing"
        }
    }
}

extension SKPaymentTransaction {
    func toString() -> String {
        return "SKPaymentTxn: \(self.payment.productIdentifier) Date: \(self.transactionDate) State: \(self.transactionState) Id: \(self.transactionIdentifier)"
    }
}

