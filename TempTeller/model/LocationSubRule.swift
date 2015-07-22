//
//  LocationSubRule.swift
//  TempTeller
//
//  Created by Ben La Monica on 7/17/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation

public class LocationSubRule : SubRule, NSCopying {
    public var name : String
    public var locId: String
    
    override convenience init() {
        self.init(name: "", locId: "")
    }
    
    convenience init(json: JSON) {
        self.init(name: json["name"].stringValue, locId: json["locId"].stringValue)
    }
    
    public init(name: String, locId: String) {
        self.name = name
        self.locId = locId
        super.init()
    }
    
    convenience init(copy: LocationSubRule) {
        self.init(name: copy.name, locId: copy.locId)
    }
    
    override public func copyWithZone(zone: NSZone) -> AnyObject {
        return LocationSubRule(copy: self)
    }
    
}