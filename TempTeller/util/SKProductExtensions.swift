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

extension SKPaymentTransaction {
    func toString() -> String {
        return "SKPaymentTxn: \(self.payment.productIdentifier) Date: \(self.transactionDate) State: \(self.transactionState.rawValue) Id: \(self.transactionIdentifier)"
    }
}