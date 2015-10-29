//
//  SwiftVBigNum_OSXTests.swift
//  SwiftVBigNum-OSXTests
//
//  Created by Danny Keogan on 10/19/15.
//  Copyright © 2015 iOS Developer Zone. All rights reserved.
//

import XCTest
@testable import SwiftVBigNum

class SwiftVBigNum_OSXTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitialization() {
        let one256 = UInt256(1)
        XCTAssertEqual(one256.description, "1")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
