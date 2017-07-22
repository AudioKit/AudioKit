//
//  AKEqualizerFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKEqualizerFilterTests: AKTestCase {

    func testDefault() {
        output = AKEqualizerFilter(input)
        AKTestMD5("73f1363cf9b147982222f6fbf9220d54")
    }

    func testParameters() {
        output = AKEqualizerFilter(input, centerFrequency: 500, bandwidth: 50, gain: 5)
        AKTestMD5("aa8dfc9bae0b87396a19ea348bb93e0d")
    }

    func testCenterFrequency() {
        output = AKEqualizerFilter(input, centerFrequency: 500)
        AKTestMD5("653eb91a5de56e485f5fb0a9eafec1af")
    }

    func testBandwidth() {
        output = AKEqualizerFilter(input, bandwidth: 50)
        AKTestMD5("61c77eabbb5ecbeb54874a397e21fa39")
    }

    func testGain() {
        output = AKEqualizerFilter(input, gain: 5)
        AKTestMD5("3eb6bc39abf442688af24817e9f9e3ba")
    }
}
