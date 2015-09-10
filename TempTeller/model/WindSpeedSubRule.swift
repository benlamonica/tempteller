//
//  WindSpeedSubRule.swift
//  TempTeller
//
//  Created by Ben La Monica on 7/17/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation

public enum SpeedUnits : String {
    case KPH = "KPH", MPH = "MPH"
}

public class WindSpeedSubRule : SingleValSubRule, ConvertableToDictionary {

    var units : SpeedUnits
    
    public init(value: Double, op: CompOp, units: SpeedUnits) {
        self.units = units
        super.init(value: value, op: op)
    }

    override init(json: JSON) {
        if let jsonUnits = json["units"].string {
            units = SpeedUnits(rawValue: jsonUnits)!
        } else {
            units = SpeedUnits.MPH
        }
        
        super.init(json: json)
    }
    
    convenience init(copy: WindSpeedSubRule) {
        self.init(value: copy.value, op: copy.op, units: copy.units)
    }
    
    convenience init() {
        self.init(value: 0, op: CompOp.EQ, units: SpeedUnits.MPH)
    }
    
    override public func copyWithZone(zone: NSZone) -> AnyObject {
        return WindSpeedSubRule(copy: self)
    }
    
    override func toDict() -> Dictionary<String, AnyObject> {
        var model = super.toDict()
        model["units"] = units.rawValue
        return model
    }
}