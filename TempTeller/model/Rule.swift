//
//  Rule.swift
//  TempTeller
//
//  Created by Ben La Monica on 7/17/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation

public class Rule : NSObject, NSCopying {
    var isEnabled : Bool;
    var subrules : [SubRule]
    var message : String {
        get {
            return (self.subrules[0] as! MessageSubRule).message
        }
    }
    public override init() {
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
    
    public init(copy: Rule) {
        self.isEnabled = copy.isEnabled
        self.subrules = copy.subrules.map({$0.copy() as! SubRule})
    }
    
    public func copyWithZone(zone: NSZone) -> AnyObject {
        return Rule(copy: self)
    }
    
    public func json() -> String {
        
        let model : [String:AnyObject] = [
            "version":"1.0",
            "isEnabled":isEnabled,
            "subrules":subrules.map({$0.toDict()})
        ]
        
        if let json = NSJSONSerialization.dataWithJSONObject(model, options: NSJSONWritingOptions.PrettyPrinted, error: nil) {
            if let jsonString =  NSString(data: json, encoding: NSUTF8StringEncoding) as? String {
                return jsonString
            }
        }
        
        return "did not work"
    }
}