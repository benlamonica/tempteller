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
    public var timeRange : (min:Int, max:Int)
    public var op : TimeOp
    override convenience init() {
        self.init(timeRange: (0,0), oper:TimeOp.AT);
    }
    
    convenience init(copy: TimeSubRule) {
        self.init(timeRange: copy.timeRange, oper: copy.op)
    }
    
    public init(timeRange: (min:Int, max:Int), oper: TimeOp) {
        self.timeRange = timeRange
        self.op = oper
        super.init()
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
