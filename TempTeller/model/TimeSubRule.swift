//
//  File.swift
//  TempTeller
//
//  Created by Ben La Monica on 7/17/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation

public enum TimeOp : String {
    case AT = "at"
    case BETWEEN = "between"
}

public class TimeSubRule : SubRule, NSCopying, ConvertableToDictionary {
    public var timeRange : (min:String, max:String)
    public var op : TimeOp
    override convenience init() {
        self.init(timeRange: ("12:00 PM", "12:00 PM"), op:TimeOp.AT);
    }
    
    convenience init(copy: TimeSubRule) {
        self.init(timeRange: copy.timeRange, op: copy.op)
    }
    
    public init(timeRange: (min:String, max:String), op: TimeOp) {
        self.timeRange = timeRange
        self.op = op
        super.init()
    }
    
    convenience init(json: JSON) {
        self.init(timeRange: (json["timeRange"]["min"].string ?? "12:00 PM", json["timeRange"]["max"].string ?? "12:00 PM"), op: TimeOp(rawValue: json["op"].stringValue)!)
    }
    
    override public func copyWithZone(zone: NSZone) -> AnyObject {
        return TimeSubRule(copy: self)
    }
    
    override func toDict() -> Dictionary<String, AnyObject> {
        var model = super.toDict()
        model["timeRange"] = ["min":timeRange.min, "max":timeRange.max]
        model["op"] = op.rawValue
        return model
    }
}
