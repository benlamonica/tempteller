//
//  Rule.swift
//  TempTeller
//
//  Created by Ben La Monica on 5/19/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation

class Location : NSObject, NSCopying {
    var name : String
    var locId: String
    
    init(name : String, locId : String = "") {
        self.name = name
        self.locId = locId
        super.init()
    }
    
    convenience init(copy: Location) {
        self.init(name: copy.name, locId: copy.locId)
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return Location(copy: self)
    }
    
}

enum CompOp : String {
    case LT = "<"
    case LTE = "<="
    case GT = ">"
    case GTE = ">="
    case EQ = "="
}

enum TimeOp : String {
    case AT = "at"
    case BETWEEN = "between"
}

enum BoolOp : String {
    case IN = "in"
    case NOT_IN = "not in"
}

class SubRule : NSObject, NSCopying {
    func copyWithZone(zone: NSZone) -> AnyObject {
        NSLog("CRITICAL: Calling copyWithZone from SubRule, this should have been overridden")
        return SubRule() // this should always be overridden, since SubRule is "abstract"
    }
}

class MessageSubRule : SubRule, NSCopying {
    var message : String;
    init(msg : String) {
        message = msg
        super.init()
    }
    
    override convenience init() {
        self.init(msg: "")
    }
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        return MessageSubRule(msg: message)
    }
}

class SingleValSubRule : SubRule, NSCopying {
    var value : Double
    var op : CompOp
    
    // in order to implement copyWithZone, this initializer must be "required", and all subclasses must implement
    required init(value: Double, op: CompOp) {
        self.value = value
        self.op = op
        super.init()
    }
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        return self.dynamicType.self(value: value, op: op)
    }
    
}

class TemperatureSubRule : SingleValSubRule {
    var isFarenheit : Bool;
    
    convenience init() {
        self.init(value: 70, op: CompOp.LT)
    }

    required init(value: Double, op: CompOp) {
        isFarenheit = true
        super.init(value: value, op: op)
    }
}


class HumiditySubRule : SingleValSubRule {
    required init(value: Double, op: CompOp) {
        super.init(value: value, op: op)
    }
    convenience init() {
        self.init(value: 0, op: CompOp.LTE)
    }
    convenience init(copy: HumiditySubRule) {
        self.init(value: copy.value, op: copy.op)
    }
}

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

class TimeSubRule : SubRule, NSCopying {
    var timeRange : (min:Int, max:Int)
    var oper : TimeOp
    override convenience init() {
        self.init(timeRange: (0,0), oper:TimeOp.AT);
    }

    convenience init(copy: TimeSubRule) {
        self.init(timeRange: copy.timeRange, oper: copy.oper)
    }
    
    init(timeRange: (min:Int, max:Int), oper: TimeOp) {
        self.timeRange = timeRange
        self.oper = oper
        super.init()
    }
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        return TimeSubRule(copy: self)
    }
}

class LocationSubRule : SubRule, NSCopying {
    var location : Location
    
    override convenience init() {
        self.init(loc: Location(name: ""))
    }
    
    init(loc: Location) {
        self.location = loc
        super.init()
    }
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        return LocationSubRule(loc: Location(copy: location))
    }
  
}

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

class ForcastConditionSubRule : ConditionSubRule {
    var forcastTime : Int
    
    init(conditions: [Condition:Bool], forcastTime: Int) {
        self.forcastTime = forcastTime
        super.init(conditions: conditions);
    }
    
    convenience init() {
        self.init(conditions: [Condition.Sunny:true], forcastTime: 12)
    }

    // have to name this something different than the super init(copy:) because swift won't let me override and change types
    convenience init(copy2: ForcastConditionSubRule) {
        self.init(conditions: copy2.conditions, forcastTime: copy2.forcastTime)
    }
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        return ForcastConditionSubRule(copy2: self)
    }
}

class Rule : NSObject, NSCopying {
    var isEnabled : Bool;
    var subrules : [SubRule]
    var message : String {
        get {
            return (self.subrules[0] as! MessageSubRule).message
        }
    }
    override init() {
        isEnabled = false;
        subrules = [
            MessageSubRule(),
            LocationSubRule(),
            TemperatureSubRule(),
            HumiditySubRule(),
            ConditionSubRule(),
            ForcastConditionSubRule(),
            ForcastTempSubRule(),
            WindSpeedSubRule()
        ]
        super.init()
    }
    
    init(copy: Rule) {
        self.isEnabled = copy.isEnabled
        self.subrules = copy.subrules.map({$0.copy() as! SubRule})
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return Rule(copy: self)
    }
}