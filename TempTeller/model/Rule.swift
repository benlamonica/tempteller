//
//  Rule.swift
//  TempTeller
//
//  Created by Ben La Monica on 7/17/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation

public class Rule : NSObject, NSCopying {
    public var isEnabled : Bool;
    public var subrules : [SubRule]
    public var uuid : String
    public var message : String {
        get {
            return (self.subrules[0] as! MessageSubRule).message
        }
    }
    
    public init(json: String) {
        let parsed = JSON(data: json.dataUsingEncoding(NSUTF8StringEncoding)!)
        self.isEnabled = parsed["isEnabled"].boolValue
        self.uuid = parsed["uuid"].stringValue
        self.subrules = []
        for parsedSubRule in parsed["subrules"].arrayValue {
            let type = parsedSubRule["type"].stringValue
            switch type {
                case "ConditionSubRule":
                    subrules.append(ConditionSubRule(json: parsedSubRule))
                case "ForcastConditionSubRule":
                    subrules.append(ForcastConditionSubRule(json: parsedSubRule))
                case "TemperatureSubRule":
                    subrules.append(TemperatureSubRule(json: parsedSubRule))
                case "ForcastTempSubRule":
                    subrules.append(ForcastTempSubRule(json: parsedSubRule))
                case "LocationSubRule":
                    subrules.append(LocationSubRule(json: parsedSubRule))
                case "MessageSubRule":
                    subrules.append(MessageSubRule(json: parsedSubRule))
                case "TimeSubRule":
                    subrules.append(TimeSubRule(json: parsedSubRule))
                case "WindSpeedSubRule":
                    subrules.append(WindSpeedSubRule(json: parsedSubRule))
                case "HumiditySubRule":
                    subrules.append(HumiditySubRule(json: parsedSubRule))
                default:
                    NSLog("Received unknown type \(type). Will skip.")
            }
        }
    }
    
    public override init() {
        isEnabled = true;
        uuid = NSUUID().UUIDString
        subrules = [
            MessageSubRule(),
            LocationSubRule(),
        ]
        super.init()
    }
    
    public init(copy: Rule) {
        self.isEnabled = copy.isEnabled
        self.uuid = copy.uuid
        self.subrules = copy.subrules.map({$0.copy() as! SubRule})
    }
    
    public func copyWithZone(zone: NSZone) -> AnyObject {
        return Rule(copy: self)
    }
    
    public func json(prettyPrint:Bool = false) -> String {
        
        let model : [String:AnyObject] = [
            "version":"1.0",
            "uuid": uuid,
            "isEnabled":isEnabled,
            "subrules":subrules.map({$0.toDict()})
        ]
        
        if let json = NSJSONSerialization.dataWithJSONObject(model, options: prettyPrint ? NSJSONWritingOptions.PrettyPrinted : nil, error: nil) {
            if let jsonString =  NSString(data: json, encoding: NSUTF8StringEncoding) as? String {
                return jsonString
            }
        }
        
        return "did not work"
    }
}