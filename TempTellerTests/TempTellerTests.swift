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
    
    let jsonResult = "{\"isEnabled\":false,\"subrules\":[{\"message\":\"\",\"type\":\"MessageSubRule\"},{\"location\":{\"locId\":\"\",\"name\":\"\"},\"type\":\"LocationSubRule\"},{\"isFarenheit\":true,\"value\":70,\"op\":\"<\",\"type\":\"TemperatureSubRule\"},{\"value\":0,\"op\":\"<=\",\"type\":\"HumiditySubRule\"},{\"conditions\":[\"sunny\"],\"type\":\"ConditionSubRule\"},{\"conditions\":[\"sunny\"],\"forcastTime\":12,\"type\":\"ForcastConditionSubRule\"},{\"isFarenheit\":true,\"value\":70,\"forcastTime\":12,\"op\":\"<\",\"type\":\"ForcastTempSubRule\"},{\"value\":0,\"op\":\"<=\",\"type\":\"WindSpeedSubRule\"}],\"version\":\"1.0\"}"

    func testJsonSerialization() {
        let rule : Rule = Rule()
        NSLog(rule.json(prettyPrint:true))
        XCTAssertEqual(rule.json(), jsonResult, "not equal")
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock() {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
