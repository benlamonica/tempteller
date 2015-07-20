//
//  ForcastConditionSubRule.swift
//  TempTeller
//
//  Created by Ben La Monica on 7/17/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation

public class ForcastConditionSubRule : ConditionSubRule {
    public var forcastTime : Int
    
    public init(conditions: [Condition:Bool], forcastTime: Int) {
        self.forcastTime = forcastTime
        super.init(conditions: conditions);
    }
    
    convenience init(json: JSON) {
        self.init(conditions: ConditionSubRule.getConditionsFromJson(json), forcastTime: json["forcastTime"].intValue)
    }
    
    convenience init() {
        self.init(conditions: [Condition.Sunny:true], forcastTime: 12)
    }
    
    // have to name this something different than the super init(copy:) because swift won't let me override and change types
    convenience init(copy2: ForcastConditionSubRule) {
        self.init(conditions: copy2.conditions, forcastTime: copy2.forcastTime)
    }
    
    override public func copyWithZone(zone: NSZone) -> AnyObject {
        return ForcastConditionSubRule(copy2: self)
    }
}