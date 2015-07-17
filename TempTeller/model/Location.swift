//
//  Location.swift
//  TempTeller
//
//  Created by Ben La Monica on 7/17/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation

class Location : NSObject, NSCopying, ConvertableToDictionary {
    var name : String
    var locId: String
    
    init(name : String, locId : String = "") {
        self.name = name
        self.locId = locId
        super.init()
    }
    
    convenience init(copy: Location) {
        self.init(name: copy.name, locId: copy.locId)
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return Location(copy: self)
    }
    
    func toDict() -> [String : AnyObject] {
        return ["name":name, "locId":locId]
    }
}
