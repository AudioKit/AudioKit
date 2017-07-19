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
        let input = AKOscillator()
        output = AKPeakLimiter(input)
        input.start()
        AKTestMD5("74e37ff4fabffe930b31a2ebc43463dc")
    }

    func testParameters() {
        let input = AKOscillator()
        output = AKPeakLimiter(input, attackTime: 0.02, decayTime: 0.03, preGain: 1)
        input.start()
        AKTestMD5("fcb613b8b2f63a58eae537f8a90c9003")
    }


    func testAttackTime() {
        let input = AKOscillator()
        output = AKPeakLimiter(input, attackTime: 0.02)
        input.start()
        AKTestMD5("b28af37f6ceafd2468faf639c55c59cf")
    }

    func testDecayTime() {
        let input = AKOscillator()
        output = AKPeakLimiter(input, decayTime: 0.03)
        input.start()
        AKTestMD5("74e37ff4fabffe930b31a2ebc43463dc")
    }

    func testPreGain() {
        let input = AKOscillator()
        output = AKPeakLimiter(input, preGain: 1)
        input.start()
        AKTestMD5("87be7fc3c0bcfd2b9472148214d598c5")
    }
}
