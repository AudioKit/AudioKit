//
//  AKPeakLimiterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKPeakLimiterTests: AKTestCase {

    func testAttackDuration() {
        output = AKPeakLimiter(input, attackDuration: 0.02)
        AKTestMD5("759ea5ae95b32dda8684ccf230627e78")
    }

    func testDecayDuration() {
        output = AKPeakLimiter(input, decayDuration: 0.03)
        AKTestMD5("f0ef43b40c91423a3f5dc194cd1311f0")
    }

    func testDefault() {
        output = AKPeakLimiter(input)
        AKTestMD5("f0ef43b40c91423a3f5dc194cd1311f0")
    }

    func testParameters() {
        output = AKPeakLimiter(input, attackDuration: 0.02, decayDuration: 0.03, preGain: 1)
        AKTestMD5("a6238632bc2114c300074ca72d78aacf")
    }

    func testPreGain() {
        output = AKPeakLimiter(input, preGain: 1)
        AKTestMD5("d5650ad2d83cde906dbf18766cbd7724")
    }
}
