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
        let input = AKOscillator()
        output = AKKorgLowPassFilter(input)
        input.start()
        AKTestMD5("60784c8de74c0ce230d4eb460dbd3904")
    }

    func testParameters() {
        let input = AKOscillator()
        output = AKKorgLowPassFilter(input, cutoffFrequency: 500, resonance: 0.5, saturation: 1)
        input.start()
        AKTestMD5("05297ca14e31523c00cf53c0e6208703")
    }

    func testCutoffFrequency() {
        let input = AKOscillator()
        output = AKKorgLowPassFilter(input, cutoffFrequency: 500)
        input.start()
        AKTestMD5("04565dcae478792f33ba0e53fdcf8010")
    }

    func testResonance() {
        let input = AKOscillator()
        output = AKKorgLowPassFilter(input, resonance: 0.5)
        input.start()
        AKTestMD5("28917fb20e85e744b04466b96d60452d")
    }

    func testSaturation() {
        let input = AKOscillator()
        output = AKKorgLowPassFilter(input, saturation: 1)
        input.start()
        AKTestMD5("232f7ce656fb1b781afacb460b15d165")
    }
}
