//
//  AKTestCase.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/17/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import XCTest
@testable import OSXAudioKit

class AKTestCase: XCTestCase {
    
    var test: UnsafeMutablePointer<sp_test> = nil
    var testInstrument: AKInstrument?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sp_test_create(&test, 2*44100)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        sp_test_destroy(&test)
    }
    
    func AKTestAssertMD5(md5: String) {
        let utf8String = (md5 as NSString).UTF8String
        XCTAssertEqual(sp_test_compare(test, utf8String), SP_OK)
    }
    
    func process(time: Int) {
        let samples = time * 44100
        
        for _ in 0..<samples {
            for operation in testInstrument!.operations {
                operation.compute()
            }
            sp_test_add_sample(test, AKManager.sharedManager.data.memory.out[0])
        }
    }
    
    func printMD5() {
        print(String(CString: test.memory.md5, encoding: NSUTF8StringEncoding))
    }
    
}
