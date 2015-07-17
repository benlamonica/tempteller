//
//  WindSpeedSubRule.swift
//  TempTeller
//
//  Created by Ben La Monica on 7/17/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation

class WindSpeedSubRule : SingleValSubRule {
    required init(value: Double, op: CompOp) {
        super.init(value: value, op: op)
    }
    convenience init(copy: WindSpeedSubRule) {
        self.init(value: copy.value, op: copy.op)
    }
    convenience init() {
        self.init(value: 0, op: CompOp.LTE)
    }
}