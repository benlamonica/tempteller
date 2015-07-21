//
//  TemperatureSubRule.swift
//  TempTeller
//
//  Created by Ben La Monica on 7/17/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation

public class TemperatureSubRule : SingleValSubRule {
    public var isFarenheit : Bool;
    
    convenience init() {
        self.init(value: 70, op: CompOp.LTE, isFarenheit: true)
    }
    
    override init(json: JSON) {
        isFarenheit = json["isFarenheit"].boolValue
        super.init(json: json)
    }

    public init(value: Double, op: CompOp, isFarenheit: Bool) {
        self.isFarenheit = isFarenheit
        super.init(value: value, op: op)
    }
    
    convenience init(copy: TemperatureSubRule) {
        self.init(value: copy.value, op: copy.op, isFarenheit: copy.isFarenheit)
    }
    
    public override func copyWithZone(zone: NSZone) -> AnyObject {
        return TemperatureSubRule(copy: self)
    }
}
