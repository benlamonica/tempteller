//
//  ConditionSubRule.swift
//  TempTeller
//
//  Created by Ben La Monica on 7/17/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum Condition : String {
    case Sunny = "sunny"
    case Cloudy = "cloudy"
    case Rainy = "rainy"
    case Lightning = "lightning"
    case Snow = "snowy"
    case Wind = "windy"
}

public enum BooleanOp : String {
    case IS = "is"
    case IS_NOT = "is not"
}

public class ConditionSubRule : SubRule {
    var conditions : [Condition:Bool];
    var op : BooleanOp
    
    override convenience init() {
        self.init(conditions: [:], op: BooleanOp.IS)
    }
    
    convenience init(copy: ConditionSubRule) {
        self.init(conditions: copy.conditions, op: copy.op)
    }
    
    public init(conditions: [Condition:Bool], op: BooleanOp) {
        self.conditions = conditions
        self.op = op
        super.init()
    }

    class func getConditionsFromJson(json: JSON) -> [Condition:Bool] {
        var conditions : [Condition:Bool] = [:]
        for condition in json["conditions"].arrayValue {
            conditions[Condition(rawValue: condition.string ?? "sunny")!] = true
        }
        return conditions
    }
    
    convenience init(json: JSON) {
        self.init(conditions: ConditionSubRule.getConditionsFromJson(json), op: BooleanOp(rawValue: json["op"].string ?? "is")!)
    }
    
    override public func copyWithZone(zone: NSZone) -> AnyObject {
        return ConditionSubRule(copy: self)
    }
    
    override func toDict() -> Dictionary<String, AnyObject> {
        var model = super.toDict()
        let filtered = conditions.keys.filter {self.conditions[$0] != nil && self.conditions[$0]!}
        let filteredConditions = filtered.map {$0.rawValue}
        model["conditions"] = Array(filteredConditions)
        model["op"] = op.rawValue
        return model
    }
}
