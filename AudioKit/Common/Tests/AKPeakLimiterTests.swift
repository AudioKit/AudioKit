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

    func testAttackTime() {
        output = AKPeakLimiter(input, attackTime: 0.02)
        AKTestMD5("759ea5ae95b32dda8684ccf230627e78")
    }

    func testDecayTime() {
        output = AKPeakLimiter(input, decayTime: 0.03)
        AKTestMD5("f0ef43b40c91423a3f5dc194cd1311f0")
    }

    func testDefault() {
        output = AKPeakLimiter(input)
        AKTestMD5("f0ef43b40c91423a3f5dc194cd1311f0")
    }

    func testParameters() {
        output = AKPeakLimiter(input, attackTime: 0.02, decayTime: 0.03, preGain: 1)
        AKTestMD5("a6238632bc2114c300074ca72d78aacf")
    }

    func testPreGain() {
        output = AKPeakLimiter(input, preGain: 1)
        AKTestMD5("d5650ad2d83cde906dbf18766cbd7724")
    }
}
