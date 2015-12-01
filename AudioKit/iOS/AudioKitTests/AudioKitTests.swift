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
    
    var duration = 2
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        print("setting up test %@", AKManager.sharedInstance.test)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        print("tearing down test %@", AKManager.sharedInstance.test)
        sp_test_destroy(&AKManager.sharedInstance.test)
    }
    
    func testFMOscillator() {
        let samples = duration * 44100
        
        let audiokit = AKManager.sharedInstance
        
        //: Try changing the table type to triangle or another AKTableType
        //: or changing the number of points to a smaller number (has to be a power of 2)
        let fm = AKFMOscillator(table: AKTable(.Sine, size: 4096))
        audiokit.testOutput(fm, samples: samples)
        var i = 0
        while audiokit.isTesting && i < 100 {
            usleep(100)
            i++
        }
        print("comparing test %@", AKManager.sharedInstance.test)
        if sp_test_compare(AKManager.sharedInstance.test, "") == 0 {
            print(calculatedMD5())
        } else {
            print("Passed")
        }

    }
    
    func calculatedMD5() -> String {
        return String(CString: AKManager.sharedInstance.test.memory.md5, encoding: NSUTF8StringEncoding)!
    }
    
}