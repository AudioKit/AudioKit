//
//  AKKorgLowPassFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKKorgLowPassFilterTests: AKTestCase {

    func testDefault() {
        output = AKKorgLowPassFilter(input)
        AKTestMD5("60784c8de74c0ce230d4eb460dbd3904")
    }

    func testParameters() {
        output = AKKorgLowPassFilter(input, cutoffFrequency: 500, resonance: 0.5, saturation: 1)
        AKTestMD5("05297ca14e31523c00cf53c0e6208703")
    }

    func testCutoffFrequency() {
        output = AKKorgLowPassFilter(input, cutoffFrequency: 500)
        AKTestMD5("04565dcae478792f33ba0e53fdcf8010")
    }

    func testResonance() {
        output = AKKorgLowPassFilter(input, resonance: 0.5)
        AKTestMD5("28917fb20e85e744b04466b96d60452d")
    }

    func testSaturation() {
        output = AKKorgLowPassFilter(input, saturation: 1)
        AKTestMD5("232f7ce656fb1b781afacb460b15d165")
    }
}
