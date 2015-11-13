//
//  TempTellerTests.swift
//  TempTellerTests
//
//  Created by Ben La Monica on 5/19/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import UIKit
import XCTest
import TempTeller
import SwiftyJSON

class TempTellerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    let jsonResult = "{\"enabled\":true,\"subrules\":[{\"type\":\"MessageSubRule\",\"message\":\"This is a message\"},{\"locId\":\"11_12784194\",\"lat\":\"37.477141\",\"lng\":\"-122.299083\",\"type\":\"LocationSubRule\",\"name\":\"Aurora, IL\"},{\"op\":\"at\",\"type\":\"TimeSubRule\",\"timeRange\":{\"max\":\"12:00 PM\",\"min\":\"12:00 PM\"}},{\"op\":\">\",\"isFarenheit\":true,\"type\":\"TemperatureSubRule\",\"value\":70},{\"op\":\"<\",\"isFarenheit\":true,\"forecastTime\":\"Today @ 3:00 AM\",\"type\":\"ForecastTempSubRule\",\"value\":30},{\"op\":\"is\",\"type\":\"ConditionSubRule\",\"conditions\":[\"snowy\"]},{\"op\":\"is not\",\"forecastTime\":\"5:00 AM\",\"type\":\"ForecastConditionSubRule\",\"conditions\":[\"lightning\"]},{\"op\":\">=\",\"units\":\"MPH\",\"type\":\"WindSpeedSubRule\",\"value\":20},{\"op\":\"<\",\"type\":\"HumiditySubRule\",\"value\":50},{\"op\":\"between\",\"type\":\"TimeSubRule\",\"timeRange\":{\"max\":\"2:00 PM\",\"min\":\"8:30 AM\"}}],\"version\":\"1.0\",\"uuid\":\"blah\"}"

    func testJsonSerialization() {
        let rule : Rule = Rule()
        rule.uuid = "blah"
        // set the 2 default rules, every rule will have a msg and a locaiton subrule.
        if let msg = rule.subrules[0] as? MessageSubRule {
            msg.message = "This is a message"
        }
        if let loc = rule.subrules[1] as? LocationSubRule {
            loc.lng = "-122.299083"
            loc.locId = "11_12784194"
            loc.lat = "37.477141"
            loc.name = "Aurora, IL"
        }
        // now add the other subrules, to test serialization
        rule.subrules.append(TemperatureSubRule(value: 70.0, op: CompOp.GT, isFarenheit: true))
        rule.subrules.append(ForecastTempSubRule(value: 30.0, op: CompOp.LT, isFarenheit: true, forecastTime: "Today @ 3:00 AM"))
        rule.subrules.append(ConditionSubRule(conditions: [Condition.Snowy:true], op: BooleanOp.IS))
        rule.subrules.append(ForecastConditionSubRule(conditions: [Condition.Foggy:true], op: BooleanOp.IS_NOT, forecastTime: "5:00 AM"))
        rule.subrules.append(WindSpeedSubRule(value: 20, op: CompOp.GTE, units: SpeedUnits.MPH))
        rule.subrules.append(HumiditySubRule(value: 50, op: CompOp.LT))
        rule.subrules.append(TimeSubRule(timeRange: ("8:30 AM","2:00 PM"), op: TimeOp.BETWEEN))
            
        XCTAssertEqual(String(rule.json().characters.sort()), String(jsonResult.characters.sort()), "not equal \n expects:\n" + jsonResult + "\nbut was:\n" + rule.json(true))
    }
    
    func testJsonDeserialization() {
        // first de-serialize
        let rule = Rule(json:JSON(data: jsonResult.dataUsingEncoding(NSUTF8StringEncoding)!))
        // then serialze again and compare..they should match
        XCTAssertEqual(String(rule.json().characters.sort()), String(jsonResult.characters.sort()), "not equal \n expects:\n" + jsonResult + "\nbut was:\n" + rule.json(true))
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock() {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
