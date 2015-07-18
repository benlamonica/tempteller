//
//  File.swift
//  TempTeller
//
//  Created by Ben La Monica on 7/17/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation

enum TimeOp : String {
    case AT = "at"
    case BETWEEN = "between"
}

class TimeSubRule : SubRule, NSCopying, ConvertableToDictionary {
    var timeRange : (min:Int, max:Int)
    var op : TimeOp
    override convenience init() {
        self.init(timeRange: (0,0), oper:TimeOp.AT);
    }
    
    convenience init(copy: TimeSubRule) {
        self.init(timeRange: copy.timeRange, oper: copy.op)
    }
    
    init(timeRange: (min:Int, max:Int), oper: TimeOp) {
        self.timeRange = timeRange
        self.op = oper
        super.init()
    }
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        return TimeSubRule(copy: self)
    }
    
    override func toDict() -> Dictionary<String, AnyObject> {
        var model = super.toDict()
        model["op"] = op.rawValue
        return model
    }
}
