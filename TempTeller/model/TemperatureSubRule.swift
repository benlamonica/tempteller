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
        self.init(value: 70, op: CompOp.LT)
    }
    
    public required init(value: Double, op: CompOp) {
        isFarenheit = true
        super.init(value: value, op: op)
    }
}
