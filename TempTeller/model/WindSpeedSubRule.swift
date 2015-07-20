//
//  WindSpeedSubRule.swift
//  TempTeller
//
//  Created by Ben La Monica on 7/17/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation

public class WindSpeedSubRule : SingleValSubRule {

    convenience init(copy: WindSpeedSubRule) {
        self.init(value: copy.value, op: copy.op)
    }
    
    override public func copyWithZone(zone: NSZone) -> AnyObject {
        return WindSpeedSubRule(copy: self)
    }
}