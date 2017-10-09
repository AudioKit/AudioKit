//
//  AKLowPassFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKLowPassFilterTests: AKTestCase {

    func testCutoffFrequency() {
        output = AKLowPassFilter(input, cutoffFrequency: 500)
        AKTestMD5("51fcc7daf05eded5b831b64ead655d06")
    }

    func testDefault() {
        output = AKLowPassFilter(input)
        AKTestMD5("218e0d52760a904835bc18e994114b59")
    }

    func testParameters() {
        output = AKLowPassFilter(input, cutoffFrequency: 500, resonance: 1)
        AKTestMD5("a2c7af17be8cf93a8eb83a15294fff33")
    }

    func testResonance() {
        output = AKLowPassFilter(input, resonance: 1)
        AKTestMD5("dfa844c957b9b4fe22a24465ec7da45b")
    }
}
