//
//  ConditionSubRule.swift
//  TempTeller
//
//  Created by Ben La Monica on 7/17/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation

enum Condition : String {
    case Sunny = "sunny"
    case Cloudy = "cloudy"
    case Rainy = "rainy"
    case Lightning = "lightning"
    case Snow = "snow"
    case Wind = "wind"
}

class ConditionSubRule : SubRule, ConvertableToDictionary {
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
    
    override func toDict() -> Dictionary<String, AnyObject> {
        var model = super.toDict()
        let filtered = conditions.keys.filter {self.conditions[$0] != nil && self.conditions[$0]!}
        let filteredConditions = filtered.map {$0.rawValue}
        model["conditions"] = filteredConditions.array
        return model
    }
}
