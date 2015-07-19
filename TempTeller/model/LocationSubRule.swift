//
//  LocationSubRule.swift
//  TempTeller
//
//  Created by Ben La Monica on 7/17/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation

public class LocationSubRule : SubRule, NSCopying {
    public var location : Location
    
    override convenience init() {
        self.init(loc: Location(name: ""))
    }
    
    public init(loc: Location) {
        self.location = loc
        super.init()
    }
    
    override public func copyWithZone(zone: NSZone) -> AnyObject {
        return LocationSubRule(loc: Location(copy: location))
    }
    
}