//
//  SubRule.swift
//  TempTeller
//
//  Created by Ben La Monica on 7/17/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation

enum CompOp : String {
    case LT = "<"
    case LTE = "<="
    case GT = ">"
    case GTE = ">="
    case EQ = "="
}

enum BoolOp : String {
    case IN = "in"
    case NOT_IN = "not in"
}

func createModel(obj: AnyObject, inout model: Dictionary<String,AnyObject>) {
    var mirror = reflect(obj)
    
    for var i = 0; i < mirror.count; i++ {
        let mirrorSuperClass = mirror[i].1.summary
        let objSuperClass = obj.classForCoder.description()
        if mirror[i].0 == "super" && mirrorSuperClass != objSuperClass {
            for var j = 0; j < mirror[i].1.count; j++ {
                if mirror[i].1[j].1.value as? AnyObject === obj {
                    continue
                }
                if let convertable = mirror[i].1[j].1.value as? ConvertableToDictionary {
                    model[mirror[i].1[j].0] = convertable.toDict()
                } else {
                    model[mirror[i].1[j].0] = mirror[i].1[j].1.value as? AnyObject
                }
                
            }
            continue
        }
        
        if let convertable = mirror[i].1.value as? ConvertableToDictionary {
            model[mirror[i].0] = convertable.toDict()
        } else {
            model[mirror[i].0] = mirror[i].1.value as? AnyObject
        }
    }
    
}

class SubRule : NSObject, NSCopying, ConvertableToDictionary {
    func copyWithZone(zone: NSZone) -> AnyObject {
        NSLog("CRITICAL: Calling copyWithZone from SubRule, this should have been overridden")
        return SubRule() // this should always be overridden, since SubRule is "abstract"
    }
    
    func toDict() -> Dictionary<String, AnyObject> {
        let className = self.classForCoder.description()
        let cellType = className.substringFromIndex(find(className,".")!.successor())
        var model : [String:AnyObject] = ["type":cellType]
        createModel(self, &model);
        return model
    }
}

class SingleValSubRule : SubRule, NSCopying {
    var value : Double
    var op : CompOp
    
    // in order to implement copyWithZone, this initializer must be "required", and all subclasses must implement
    required init(value: Double, op: CompOp) {
        self.value = value
        self.op = op
        super.init()
    }
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        return self.dynamicType.self(value: value, op: op)
    }
    
}
