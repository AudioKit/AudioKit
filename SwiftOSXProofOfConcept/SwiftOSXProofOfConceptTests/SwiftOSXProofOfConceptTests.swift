//
//  SwiftOSXProofOfConceptTests.swift
//  SwiftOSXProofOfConceptTests
//
//  Created by Aurelius Prochazka on 9/5/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

import Cocoa
import XCTest

class SwiftOSXProofOfConceptTests: XCTestCase {
    
    var test: UnsafeMutablePointer<sp_test> = nil
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sp_test_create(&test, 10*44100)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        sp_test_destroy(&test)
    }
    
    func testExample() {
        // This is an example of a functional test case.
        
        /** The demo instrument */
        let testInstrument = DemoInstrument()
        
        let samples = 10 * 44100
        
        let md5 = "2b2690445f03ff9b6649ff03332baf71"
        let md52 = (md5 as NSString).UTF8String
        
        for _ in 0..<samples {
            for operation in testInstrument.operations {
                operation.compute()
            }
            sp_test_add_sample(test, AKManager.sharedManager.data.memory.out[0])
        }
        print(String(CString: test.memory.md5, encoding: NSUTF8StringEncoding))
        sp_test_compare(test, md52)
        let calculatedMD5 = String(CString: test.memory.md5, encoding: NSUTF8StringEncoding)
        XCTAssertEqual(md5, calculatedMD5)    
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
