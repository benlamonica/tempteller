//
//  SubRule.swift
//  TempTeller
//
//  Created by Ben La Monica on 7/17/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation

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


func createModelFrom(mirror: MirrorType, #superclassName: String, inout #model: Dictionary<String,AnyObject>) {
    
    for var i = 0; i < mirror.count; i++ {
        let mirrorSuperClass = mirror[i].1.summary
        if mirror[i].0 == "super" && mirrorSuperClass != superclassName {
            createModelFrom(mirror[i].1, superclassName: superclassName, model: &model)
            continue
        }
        
        if let convertable = mirror[i].1.value as? ConvertableToDictionary {
            model[mirror[i].0] = convertable.toDict()
        } else {
            model[mirror[i].0] = mirror[i].1.value as? AnyObject
        }
    }
    
}

public class SubRule : NSObject, NSCopying, ConvertableToDictionary {
    public func copyWithZone(zone: NSZone) -> AnyObject {
        NSLog("CRITICAL: Calling copyWithZone from SubRule, this should have been overridden")
        return SubRule() // this should always be overridden, since SubRule is "abstract"
    }
    
    func toDict() -> Dictionary<String, AnyObject> {
        let className = self.classForCoder.description()
        let cellType = className.substringFromIndex(find(className,".")!.successor())
        var model : [String:AnyObject] = ["type":cellType]
        createModelFrom(reflect(self), superclassName: cellType, model: &model)
        return model
    }
}

public class SingleValSubRule : SubRule, NSCopying, ConvertableToDictionary {
    public var value : Double
    public var op : CompOp
    
    // in order to implement copyWithZone, this initializer must be "required", and all subclasses must implement
    public required init(value: Double, op: CompOp) {
        self.value = value
        self.op = op
        super.init()
    }
    
    override public func copyWithZone(zone: NSZone) -> AnyObject {
        return self.dynamicType.self(value: value, op: op)
    }
    
    override func toDict() -> Dictionary<String, AnyObject> {
        var model = super.toDict()
        model["op"] = op.rawValue
        return model
    }
    
}
