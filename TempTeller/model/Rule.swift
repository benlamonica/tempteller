//
//  Rule.swift
//  TempTeller
//
//  Created by Ben La Monica on 7/17/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation

public class Rule : NSObject, NSCopying, ConvertableToDictionary {
    public var enabled : Bool;
    public var subrules : [SubRule]
    public var uuid : String
    var saved = true // will be marked as true if the user hit the "Save" button after editing
    public var message : String {
        get {
            return (self.subrules[0] as! MessageSubRule).message
        }
    }
    
    public init(json: JSON) {
        self.enabled = json["enabled"].boolValue
        self.uuid = json["uuid"].stringValue
        self.subrules = []
        for jsonSubRule in json["subrules"].arrayValue {
            let type = jsonSubRule["type"].stringValue
            switch type {
                case "ConditionSubRule":
                    subrules.append(ConditionSubRule(json: jsonSubRule))
                case "ForecastConditionSubRule":
                    subrules.append(ForecastConditionSubRule(json: jsonSubRule))
                case "TemperatureSubRule":
                    subrules.append(TemperatureSubRule(json: jsonSubRule))
                case "ForecastTempSubRule":
                    subrules.append(ForecastTempSubRule(json: jsonSubRule))
                case "LocationSubRule":
                    subrules.append(LocationSubRule(json: jsonSubRule))
                case "MessageSubRule":
                    subrules.append(MessageSubRule(json: jsonSubRule))
                case "TimeSubRule":
                    subrules.append(TimeSubRule(json: jsonSubRule))
                case "WindSpeedSubRule":
                    subrules.append(WindSpeedSubRule(json: jsonSubRule))
                case "HumiditySubRule":
                    subrules.append(HumiditySubRule(json: jsonSubRule))
                default:
                    NSLog("Received unknown type \(type). Will skip.")
            }
        }
    }
    
    public override init() {
        enabled = true;
        uuid = NSUUID().UUIDString
        subrules = [
            MessageSubRule(),
            LocationSubRule(),
            TimeSubRule()
        ]
        super.init()
    }
    
    public init(copy: Rule) {
        self.enabled = copy.enabled
        self.uuid = copy.uuid
        self.subrules = copy.subrules.map({$0.copy() as! SubRule})
    }
    
    public func copyWithZone(zone: NSZone) -> AnyObject {
        return Rule(copy: self)
    }
    
    func toDict() -> [String : AnyObject] {
        let model : [String:AnyObject] = [
            "version":"1.0",
            "uuid": uuid,
            "enabled":enabled,
            "subrules":subrules.map({$0.toDict()})
        ]
        
        return model
    }
    
    public func json(prettyPrint:Bool = false) -> String {
        let model = toDict()
        
        if let json = NSJSONSerialization.dataWithJSONObject(model, options: prettyPrint ? NSJSONWritingOptions.PrettyPrinted : nil, error: nil) {
            if let jsonString =  NSString(data: json, encoding: NSUTF8StringEncoding) as? String {
                return jsonString
            }
        }
        
        return "did not work"
    }
}