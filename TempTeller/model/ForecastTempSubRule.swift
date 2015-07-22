//
//  ForecastTempSubRule.swift
//  TempTeller
//
//  Created by Ben La Monica on 7/17/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation

public class ForecastTempSubRule : TemperatureSubRule {
    public var forecastTime : Int
    
    convenience init() {
        self.init(value: 70, op: CompOp.EQ, isFarenheit: true, forecastTime:12)
    }
    
    override init(json: JSON) {
        forecastTime = json["forecastTime"].intValue
        super.init(json: json)
    }
    
    public init(value: Double, op: CompOp, isFarenheit: Bool, forecastTime: Int) {
        self.forecastTime = forecastTime
        super.init(value: value, op: op, isFarenheit: isFarenheit);
    }
    
    convenience init(copyForecastTemp copy: ForecastTempSubRule) {
        self.init(value: copy.value, op: copy.op, isFarenheit: copy.isFarenheit, forecastTime: copy.forecastTime)
    }
    
    override public func copyWithZone(zone: NSZone) -> AnyObject {
        return ForecastTempSubRule(copyForecastTemp: self)
    }
}
