//
//  HumiditySubRule.swift
//  TempTeller
//
//  Created by Ben La Monica on 7/17/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation
import SwiftyJSON

public class HumiditySubRule : SingleValSubRule {
    init(copy: HumiditySubRule) {
        super.init(value: copy.value, op: copy.op)
    }
    
    convenience init() {
        self.init(value: 0, op: CompOp.EQ)
    }
    override public init(value: Double, op: CompOp) {
        super.init(value: value, op: op)
    }

    override init(json: JSON) {
        super.init(json: json)
    }
    
    override public func copyWithZone(zone: NSZone) -> AnyObject {
        return HumiditySubRule(copy: self)
    }
}