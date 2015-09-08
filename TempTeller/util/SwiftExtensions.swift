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

infix operator =~ { associativity left precedence 130 }
func =~<T: RegularExpressionMatchable> (left: T, right: String) -> Bool {
    return left.match(right, options: nil)
}

extension String {
    func toDouble() -> Double {
        return (self as NSString).doubleValue
    }
    
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
}

extension Double {
    func format() -> String {
        return NSString(format: "%g", self) as String
    }
}