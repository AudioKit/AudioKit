//
//  AKThreePoleLowpassFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKThreePoleLowpassFilterTests: AKTestCase {

    func testDefault() {
        output = AKThreePoleLowpassFilter(input)
        AKTestMD5("8c459009f9b7a720bd2b7207ae41749f")
    }

    func testParameters() {
        output = AKThreePoleLowpassFilter(input, distortion: 1, cutoffFrequency: 500, resonance: 1)
        AKTestMD5("8444cb9f343b3d2fd1f000b4311e507f")
    }

    func testDistortion() {
        output = AKThreePoleLowpassFilter(input, distortion: 1)
        AKTestMD5("13de898944214b2c9ef90673c38c5d9d")
    }

    func testCutoffFrequency() {
        output = AKThreePoleLowpassFilter(input, cutoffFrequency: 500)
        AKTestMD5("e06aa835939a83cad47af2187341eb65")
    }

    func testResonance() {
        output = AKThreePoleLowpassFilter(input, resonance: 1)
        AKTestMD5("dac3c4ccd10c34296d6551652c8d172c")
    }
}
