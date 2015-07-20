//
//  ForcastTempSubRule.swift
//  TempTeller
//
//  Created by Ben La Monica on 7/17/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation

public class ForcastTempSubRule : TemperatureSubRule {
    public var forcastTime : Int
    
    override init(json: JSON) {
        forcastTime = json["forcastTime"].intValue
        super.init(json: json)
    }
    
    public init(value: Double, op: CompOp, isFarenheit: Bool, forcastTime: Int) {
        self.forcastTime = forcastTime
        super.init(value: value, op: op, isFarenheit: isFarenheit);
    }
    
    convenience init(copy: ForcastTempSubRule) {
        self.init(value: copy.value, op: copy.op, isFarenheit: copy.isFarenheit, forcastTime: copy.forcastTime)
    }
    
    override public func copyWithZone(zone: NSZone) -> AnyObject {
        return ForcastTempSubRule(copy: self)
    }
}
