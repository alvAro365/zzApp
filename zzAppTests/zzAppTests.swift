//
//  zzAppTests.swift
//  zzAppTests
//
//  Created by Alvar Aronija on 2018-09-05.
//  Copyright © 2018 Alvar Aronija. All rights reserved.
//

import XCTest
@testable import zzApp

class zzAppTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitialUserState() {
//        let user = User(id: "1234", healthPoints: 0)
//
//        XCTAssertEqual(user.id, "1234", "User id should be '1234'")
//        XCTAssertEqual(user.healthPoints, 0, "User hp should be 0")
        
    }
    
    func testGetCurrentLevel() {
        let dataHelper = DataProvider()
        XCTAssertEqual(dataHelper.getCurrentLevel(1), "Silver", "1 health points should be equalt to 'Silver' level")
        XCTAssertEqual(dataHelper.getCurrentLevel(2), "Gold", "2 health points should be equalt to 'Silver' level")
        XCTAssertEqual(dataHelper.getCurrentLevel(3), "Platinum", "3 health points should be equalt to 'Silver' level")
        XCTAssertEqual(dataHelper.getCurrentLevel(4), "Diamond", "4 health points should be equalt to 'Silver' level")
    }
    
}
