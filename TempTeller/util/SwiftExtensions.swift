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
    func match(pattern: String, options: NSRegularExpressionOptions = []) -> Bool {
        let regex = try? NSRegularExpression(pattern: pattern, options: options)
        return regex!.numberOfMatchesInString(self, options: [], range: NSMakeRange(0, self.characters.count)) != 0
    }
}

infix operator =~ { associativity left precedence 130 }
func =~<T: RegularExpressionMatchable> (left: T, right: String) -> Bool {
    return left.match(right, options: [])
}

extension String {
    func toDouble() -> Double {
        return (self as NSString).doubleValue
    }
    
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    func split(delim:String) -> [String] {
        return self.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: delim))
    }
    
    /**
     A simple extension to the String object to encode it for web request.
     
     :returns: Encoded version of of string it was called as.
     */
    var escaped: String? {
        let set = NSMutableCharacterSet()
        set.formUnionWithCharacterSet(NSCharacterSet.URLQueryAllowedCharacterSet())
        set.removeCharactersInString("[].:/?&=;+!@#$()',*\"") // remove the HTTP ones from the set.
        return self.stringByAddingPercentEncodingWithAllowedCharacters(set)
    }
}

extension Double {
    func format() -> String {
        return NSString(format: "%g", self) as String
    }
}