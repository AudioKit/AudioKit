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

    func testCutoffFrequency() {
        output = AKLowShelfFilter(input, cutoffFrequency: 100, gain: 1)
        AKTestMD5("68e04198919d35f039c160f630c558c3")
    }

    func testDefault() {
        output = AKLowShelfFilter(input)
        AKTestNoEffect()
    }

    func testGain() {
        output = AKLowShelfFilter(input, gain: 1)
        AKTestMD5("fd5c5287d9a7a39277eb735ceaa22d9c")
    }
}
