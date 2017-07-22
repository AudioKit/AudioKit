//
//  AKHighPassFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKHighPassFilterTests: AKTestCase {

    func testDefault() {
        output = AKHighPassFilter(input)
        AKTestMD5("c424cf5a476a13999080fb9ca86f858f")
    }

    func testParameters() {
        output = AKHighPassFilter(input, cutoffFrequency: 500, resonance: 1)
        AKTestMD5("50672c93e1af1a758d3cea771cadda59")
    }

    func testCutoffFrequency() {
        output = AKHighPassFilter(input, cutoffFrequency: 500)
        AKTestMD5("5bf4d6da07d10103c6acabf3f94d4da3")
    }

    func testResonance() {
        output = AKHighPassFilter(input, resonance: 1)
        AKTestMD5("ff7d3fadec7aaf9010b265ba37b9aba7")
    }
}
