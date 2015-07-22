//
//  ConditionSubRule.swift
//  TempTeller
//
//  Created by Ben La Monica on 7/17/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation

public class ForecastConditionSubRule : ConditionSubRule {
    public var forecastTime : Int
    
    public init(conditions: [Condition:Bool], forecastTime: Int) {
        self.forecastTime = forecastTime
        super.init(conditions: conditions);
    }
    
    convenience init(json: JSON) {
        self.init(conditions: ConditionSubRule.getConditionsFromJson(json), forecastTime: json["forecastTime"].intValue)
    }
    
    convenience init() {
        self.init(conditions: [:], forecastTime: 12)
    }
    
    // have to name this something different than the super init(copy:) because swift won't let me override and change types
    convenience init(copyForecastCondition copy: ForecastConditionSubRule) {
        self.init(conditions: copy.conditions, forecastTime: copy.forecastTime)
    }
    
    override public func copyWithZone(zone: NSZone) -> AnyObject {
        return ForecastConditionSubRule(copyForecastCondition: self)
    }
}