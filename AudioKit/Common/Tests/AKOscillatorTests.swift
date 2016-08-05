//
//  AKOscillatorTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/4/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
@testable import AudioKit

class AKOscillatorTests: AKTestCase {

    var duration = 0.1
    
    func testOscillator() {
        let osc = AKOscillator(waveform: AKTable(.Sine, size: 4096))
        AudioKit.testOutput(osc, duration: duration)
        let expectedMD5 = "221e422c2ced547a391a18900ef08516"
        let md5 = AudioKit.tester!.MD5
        XCTAssertEqual(expectedMD5, md5)
    }

}
