//
//  STTKTreeDescriptionTests.swift
//  Street Trees
//
//  Created by Tommy Lee on 8/2/16.
//  Copyright © 2016 Code for Orlando. All rights reserved.
//

import XCTest
@testable import StreetTreesTransportKit

class STTKTreeDescriptionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
  
    func testInitWithAnyString() {
        let treeDescription = STTKTreeDescription(json: "{}")
        XCTAssert(treeDescription == nil)
    }
  
    func testInitWithFullJSON() {
        let json_string:[String:String] = [
            "description" : "Highly adaptable to urban soils, the Chinese Pistache's...",
            "full_sun" : "1",
            "leaf" : "Deciduous",
            "max_height_cm" : "10.67",
            "max_width_cm" : "10.67",
            "min_height_cm" : "7.62",
            "min_width_cm" : "7.62",
            "name" : "Chinese Pistache",
            "partial_shade" : "1",
            "partial_sun" : "1",
            "shape" : "Symmetrical",
            "soil" : "clay;sand"
        ]
    
        let treeDescription = STTKTreeDescription(json: json_string)
  
        XCTAssert(treeDescription != nil)
    }

  
    func testInitWithNonJSONString() {
        let treeDescription = STTKTreeDescription(json: "testString")
        XCTAssert(treeDescription == nil)
    }
  
    func testInitWithPartialJSON() {
        let json_string:[String:String] = [
          "description" : "Highly adaptable to urban soils, the Chinese Pistache's...",
          "full_sun" : "1",
          "leaf" : "Deciduous",
          "max_height_cm" : "10.67",
          "max_width_cm" : "10.67",
          "min_height_cm" : "7.62",
          "min_width_cm" : "7.62",
          "name" : "Chinese Pistache",
          "partial_shade" : "1",
          "partial_sun" : "1",
          "shape" : "Symmetrical"
        ]

        let treeDescription = STTKTreeDescription(json: json_string)

        XCTAssert(treeDescription == nil)
    }
  
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
