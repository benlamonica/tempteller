//
//  Rule.swift
//  TempTeller
//
//  Created by Ben La Monica on 5/19/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation

// struct so that it copies
struct Location {
    var name : String
    var zip : String?
    var coords : (long : Double, lat : Double)?
    var woeId: String
    
    init(name : String, zip : String = "", coords: (long : Double, lat : Double) = (0,0), woeId : String = "") {
        self.name = name
        self.zip = zip
        self.coords = coords
        self.woeId = woeId
    }
}

class Rule : NSObject, Printable {
    var tempRange : (min:Double, max:Double);
    var humidityRange: (min:Double, max:Double);
    var timeRange : Range<Int>;
    var isFarenheit : Bool;
    var isEnabled : Bool;
    var message : String;
    var lastTime : String?;
    var lastHumidity : Int?;
    var lastTemp : Int?;
    var location : Location?;
    
    override init() {
        isEnabled = false;
        isFarenheit = true;
        message = "It is nice outside"
        tempRange = (70,70)
        humidityRange = (0,0)
        timeRange = 0830..<0930
        super.init()
    }
    
    override var description: String {
        return "Temp: \(tempRange), Humidity: \(humidityRange), Time: \(timeRange)"
    }

}