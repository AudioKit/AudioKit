//
//  AudioKitTests.swift
//  AudioKitTests
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
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
        let samples = duration * AKSettings.sampleRate
        
        //: Try changing the table type to triangle or another AKTableType
        //: or changing the number of points to a smaller number (has to be a power of 2)
        let fm = AKFMOscillator(waveform: AKTable(.Sine, size: 4096))
        AKManager.testOutput(fm, samples: samples)
        AKManager.start()
        print("IS testing %@", AKManager.tester!.isTesting())
        while AKManager.tester!.isTesting() {
            usleep(10)
        }
        print("Got this MD5: \(AKManager.tester!.getMD5())")
    }

    
}
