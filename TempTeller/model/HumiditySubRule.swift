//
//  HumiditySubRule.swift
//  TempTeller
//
//  Created by Ben La Monica on 7/17/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation

public class HumiditySubRule : SingleValSubRule {
    public required init(value: Double, op: CompOp) {
        super.init(value: value, op: op)
    }
    convenience init() {
        self.init(value: 0, op: CompOp.LTE)
    }
    convenience init(copy: HumiditySubRule) {
        self.init(value: copy.value, op: copy.op)
    }
}