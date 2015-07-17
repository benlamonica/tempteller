//
//  ConditionSubRule.swift
//  TempTeller
//
//  Created by Ben La Monica on 7/17/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation

enum Condition : Int {
    case Sunny = 1, Cloudy, Rainy, Lightning, Snow, Wind
}

class ConditionSubRule : SubRule {
    var conditions : [Condition:Bool];
    
    override convenience init() {
        self.init(conditions: [Condition.Sunny:true])
    }
    
    convenience init(copy: ConditionSubRule) {
        self.init(conditions: copy.conditions)
    }
    
    init(conditions: [Condition:Bool]) {
        self.conditions = conditions
        super.init()
    }
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        return ConditionSubRule(copy: self)
    }
}
