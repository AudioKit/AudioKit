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
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFMOscillator() {
        let samples = duration * 44100
        
        let audiokit = AKManager.sharedInstance
        
        //: Try changing the table type to triangle or another AKTableType
        //: or changing the number of points to a smaller number (has to be a power of 2)
        let fm = AKFMOscillator(table: AKTable(.Sine, size: 4096))
        audiokit.testOutput(fm, samples: samples)
        audiokit.start()
        print("IS testing %@", AKManager.sharedInstance.tester!.isTesting())
        while AKManager.sharedInstance.tester!.isTesting() {
            usleep(10)
        }
        print("Got this MD5: \(AKManager.sharedInstance.tester!.getMD5())")
    }

    
}