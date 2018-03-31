//
//  AKKorgLowPassFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKKorgLowPassFilterTests: AKTestCase {

    func testCutoffFrequency() {
        output = AKKorgLowPassFilter(input, cutoffFrequency: 500)
        AKTestMD5("fbf3766bebe59477f0d32cb7cf9711f5")
    }

    func testDefault() {
        output = AKKorgLowPassFilter(input)
        AKTestMD5("48a0ef99290f24af691818f28b2a214a")
    }

    func testParameters() {
        output = AKKorgLowPassFilter(input, cutoffFrequency: 500, resonance: 0.5, saturation: 1)
        AKTestMD5("b1a571b7cb02b511aa2ab6896bcaa807")
    }

    func testResonance() {
        output = AKKorgLowPassFilter(input, resonance: 0.5)
        AKTestMD5("97e034e7c8ae33a61cb9a8dbe7534c55")
    }

    func testSaturation() {
        output = AKKorgLowPassFilter(input, saturation: 1)
        AKTestMD5("5fff20b333cc2575c08f7bec53dc33e0")
    }
}
