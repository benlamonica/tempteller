//
//  Regex.swift
//  TempTeller
//
//  Created by Ben La Monica on 5/23/15.
//

import Foundation

// found at http://nshipster.com/swift-operators/

protocol RegularExpressionMatchable {
    func match(pattern: String, options: NSRegularExpressionOptions) -> Bool
}

extension String: RegularExpressionMatchable {
    func match(pattern: String, options: NSRegularExpressionOptions = nil) -> Bool {
        let regex = NSRegularExpression(pattern: pattern, options: options, error: nil)
        return regex!.numberOfMatchesInString(self, options: nil, range: NSMakeRange(0, count(self))) != 0
    }
}

extension String {
    func toDouble() -> Double {
        return (self as NSString).doubleValue
    }    
}

extension Double {
    func format() -> String {
        return NSString(format: "%g", self) as String
    }
}