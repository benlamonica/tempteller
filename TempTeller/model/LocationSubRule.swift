//
//  LocationSubRule.swift
//  TempTeller
//
//  Created by Ben La Monica on 7/17/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation
import SwiftyJSON

public class LocationSubRule : SubRule {
    public var name : String
    public var lng: String
    public var lat: String
    
    override convenience init() {
        self.init(name: "", lng: "", lat: "")
    }
    
    convenience init(json: JSON) {
        self.init(name: json["name"].stringValue, lng: json["lng"].string ?? "", lat: json["lat"].string ?? "" )
    }
    
    public init(name: String, lng: String, lat: String) {
        self.name = name
        self.lng = lng
        self.lat = lat
        super.init()
    }
    
    convenience init(copy: LocationSubRule) {
        self.init(name: copy.name, lng: copy.lng, lat: copy.lat)
    }
    
    override public func copyWithZone(zone: NSZone) -> AnyObject {
        return LocationSubRule(copy: self)
    }
    
}