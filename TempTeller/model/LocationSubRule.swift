//
//  LocationSubRule.swift
//  TempTeller
//
//  Created by Ben La Monica on 7/17/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation

class LocationSubRule : SubRule, NSCopying {
    var location : Location
    
    override convenience init() {
        self.init(loc: Location(name: ""))
    }
    
    init(loc: Location) {
        self.location = loc
        super.init()
    }
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        return LocationSubRule(loc: Location(copy: location))
    }
    
}