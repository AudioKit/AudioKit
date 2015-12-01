//
//  AudioKitTests.swift
//  AudioKitTests
//
//  Created by Aurelius Prochazka on 11/30/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import XCTest
@testable import AudioKit

class AKTestCase: XCTestCase {
    
    var test = AKManager.sharedInstance.test
    var duration = 2
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        sp_test_destroy(&AKManager.sharedInstance.test)
    }
    
    func testFMOscillator() {
        let samples = duration * 44100
        
        let audiokit = AKManager.sharedInstance
        
        //: Try changing the table type to triangle or another AKTableType
        //: or changing the number of points to a smaller number (has to be a power of 2)
        let fm = AKFMOscillator(table: AKTable(.Sine, size: 4096))
//        audiokit.audioOutput = fm
        audiokit.testOutput(fm, samples: samples)
        while audiokit.isTesting {
            usleep(100)
        }
        
//        if let testInst = testInstrument  {
//            for _ in 0..<samples {
//                for operation in testInst.operations {
//                    operation.compute()
//                }
//                /sp_test_add_sample(test, AKManager.sharedInstance.data.memory.out[0])
//            }
//        }
//        sp_test_compare(test, "")
    }
    
    func calculatedMD5() -> String {
        return String(CString: test.memory.md5, encoding: NSUTF8StringEncoding)!
    }
    
}