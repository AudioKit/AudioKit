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
    var duration: UInt32 = 2
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sp_test_create(&test, duration * 44100)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        sp_test_destroy(&test)
    }
    
    func process() {
        let samples = duration * 44100
        
        if let testInst = testInstrument  {
            for _ in 0..<samples {
                for operation in testInst.operations {
                    operation.compute()
                }
                sp_test_add_sample(test, AKManager.sharedManager.data.memory.out[0])
            }
        }
        sp_test_compare(test, "")
    }
    
    func calculatedMD5() -> String {
        return String(CString: test.memory.md5, encoding: NSUTF8StringEncoding)!
    }
    
}
