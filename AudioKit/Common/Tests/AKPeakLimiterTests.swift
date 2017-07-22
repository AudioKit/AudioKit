//
//  AKPeakLimiterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKPeakLimiterTests: AKTestCase {

    func testDefault() {
        output = AKPeakLimiter(input)
        AKTestMD5("74e37ff4fabffe930b31a2ebc43463dc")
    }

    func testParameters() {
        output = AKPeakLimiter(input, attackTime: 0.02, decayTime: 0.03, preGain: 1)
        AKTestMD5("fcb613b8b2f63a58eae537f8a90c9003")
    }


    func testAttackTime() {
        output = AKPeakLimiter(input, attackTime: 0.02)
        AKTestMD5("b28af37f6ceafd2468faf639c55c59cf")
    }

    func testDecayTime() {
        output = AKPeakLimiter(input, decayTime: 0.03)
        AKTestMD5("74e37ff4fabffe930b31a2ebc43463dc")
    }

    func testPreGain() {
        output = AKPeakLimiter(input, preGain: 1)
        AKTestMD5("87be7fc3c0bcfd2b9472148214d598c5")
    }
}
