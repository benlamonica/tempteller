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
    
    func testJsonSerialization() {
        let rule : Rule = Rule()
        
        XCTAssertEqual(rule.json(), "Something", "not equal")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
