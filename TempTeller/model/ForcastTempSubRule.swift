//
//  ForcastTempSubRule.swift
//  TempTeller
//
//  Created by Ben La Monica on 7/17/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation

class ForcastTempSubRule : TemperatureSubRule {
    var forcastTime : Int
    
    init(value: Double, op: CompOp, forcastTime: Int) {
        self.forcastTime = forcastTime
        super.init(value: value, op: op);
    }
    
    convenience init() {
        self.init(value: 70, op: CompOp.LT, forcastTime: 12)
    }
    
    convenience required init(value: Double, op: CompOp) {
        self.init(value: value, op: op, forcastTime: 12)
    }
    
    convenience init(copy: ForcastTempSubRule) {
        self.init(value: copy.value, op: copy.op, forcastTime: copy.forcastTime)
    }
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        return ForcastTempSubRule(copy: self)
    }
}
