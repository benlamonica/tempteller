//
//  SubRule.swift
//  TempTeller
//
//  Created by Ben La Monica on 7/17/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum CompOp : String {
    case LT = "<"
    case LTE = "<="
    case GT = ">"
    case GTE = ">="
    case EQ = "="
}

public enum BoolOp : String {
    case IN = "in"
    case NOT_IN = "not in"
}


func createModelFrom(mirror: Mirror, inout model: Dictionary<String,AnyObject>) {

    if let superMirror = mirror.superclassMirror() {
        createModelFrom(superMirror, model: &model)
    }

    for child in mirror.children {
        if let convertable = child.value as? ConvertableToDictionary {
            model[child.label!] = convertable.toDict()
        } else {
            model[child.label!] = child.value as? AnyObject
        }
    }
    
}

public class SubRule : NSObject, NSCopying, ConvertableToDictionary {
    public func copyWithZone(zone: NSZone) -> AnyObject {
        NSLog("CRITICAL: Calling copyWithZone from SubRule, this should have been overridden")
        NSException(name:"UnimplementedException", reason:"Should never get here, subclass should have implemented", userInfo: nil).raise()
        return SubRule()
    }
    
    func toDict() -> Dictionary<String, AnyObject> {
        let className = self.classForCoder.description()
        let cellType = className.substringFromIndex(className.characters.indexOf(".")!.successor())
        var model : [String:AnyObject] = ["type":cellType]
        createModelFrom(Mirror(reflecting:self), model: &model)
        return model
    }
}

public class SingleValSubRule : SubRule {
    public var value : Double
    public var op : CompOp
    
    public init(value: Double, op: CompOp) {
        self.value = value
        self.op = op
        super.init()
    }
    
    init(json: JSON) {
        self.value = json["value"].doubleValue
        self.op = CompOp(rawValue: json["op"].stringValue)!
        super.init()
    }
    
    override public func copyWithZone(zone: NSZone) -> AnyObject {
        NSLog("CRITICAL: Calling copyWithZone from SingleValueSubRule, this should have been overridden")
        NSException(name:"UnimplementedException", reason:"Should never get here, subclass should have implemented", userInfo: nil).raise()
        return SingleValSubRule(value: self.value, op: self.op)
    }
    
    override func toDict() -> Dictionary<String, AnyObject> {
        var model = super.toDict()
        model["op"] = op.rawValue
        return model
    }
}
