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

class TempTellerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    let jsonResult = "{\"uuid\":\"blah\",\"subrules\":[{\"message\":\"This is a message\",\"type\":\"MessageSubRule\"},{\"location\":{\"locId\":\"123456\",\"name\":\"Aurora, IL\"},\"type\":\"LocationSubRule\"},{\"isFarenheit\":true,\"value\":70,\"op\":\">\",\"type\":\"TemperatureSubRule\"},{\"isFarenheit\":true,\"value\":30,\"forcastTime\":3,\"op\":\"<\",\"type\":\"ForcastTempSubRule\"},{\"conditions\":[\"snow\"],\"type\":\"ConditionSubRule\"},{\"conditions\":[\"lightning\"],\"forcastTime\":5,\"type\":\"ForcastConditionSubRule\"},{\"value\":20,\"units\":\"MPH\",\"op\":\">=\",\"type\":\"WindSpeedSubRule\"},{\"value\":50,\"op\":\"<\",\"type\":\"HumiditySubRule\"},{\"timeRange\":{\"min\":830,\"max\":1400},\"op\":\"between\",\"type\":\"TimeSubRule\"}],\"version\":\"1.0\",\"isEnabled\":true}"

    func testJsonSerialization() {
        var rule : Rule = Rule()
        rule.uuid = "blah"
        // set the 2 default rules, every rule will have a msg and a locaiton subrule.
        if var msg = rule.subrules[0] as? MessageSubRule {
            msg.message = "This is a message"
        }
        if var loc = rule.subrules[1] as? LocationSubRule {
            loc.location.locId = "123456"
            loc.location.name = "Aurora, IL"
        }
        // now add the other subrules, to test serialization
        rule.subrules.append(TemperatureSubRule(value: 70.0, op: CompOp.GT, isFarenheit: true))
        rule.subrules.append(ForcastTempSubRule(value: 30.0, op: CompOp.LT, isFarenheit: true, forcastTime: 3))
        rule.subrules.append(ConditionSubRule(conditions: [Condition.Snow:true]))
        rule.subrules.append(ForcastConditionSubRule(conditions: [Condition.Lightning:true], forcastTime: 5))
        rule.subrules.append(WindSpeedSubRule(value: 20, op: CompOp.GTE, units: SpeedUnits.MPH))
        rule.subrules.append(HumiditySubRule(value: 50, op: CompOp.LT))
        rule.subrules.append(TimeSubRule(timeRange: (830,1400), op: TimeOp.BETWEEN))
            
        XCTAssertEqual(rule.json(), jsonResult, "not equal " + rule.json(prettyPrint: true))
    }
    
    func testJsonDeserialization() {
        // first de-serialize
        let rule = Rule(json:JSON(data: jsonResult))
        // then serialze again and compare..they should match
        XCTAssertEqual(rule.json(), jsonResult, "not equal " + rule.json(prettyPrint: true))
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock() {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
