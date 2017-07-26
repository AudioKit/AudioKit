//
//  AKLowShelfFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKLowShelfFilterTests: AKTestCase {

    func testDefault() {
        output = AKLowShelfFilter(input)
        AKTestNoEffect()
    }

    func testCutoffFrequency() {
        output = AKLowShelfFilter(input, cutoffFrequency: 100, gain: 1)
        AKTestMD5("6b5611186ee54e8ede60ab68f5ada69d")
    }

    func testGain() {
        output = AKLowShelfFilter(input, gain: 1)
        AKTestMD5("ef250915f7d4a375ef036cddd9ab2e89")
    }
}
