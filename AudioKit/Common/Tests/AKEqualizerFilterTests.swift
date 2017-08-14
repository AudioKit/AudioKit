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

    func testBandwidth() {
        output = AKEqualizerFilter(input, bandwidth: 50)
        AKTestMD5("e1df5bd2c1798844109c8d6c9df29eca")
    }

    func testCenterFrequency() {
        output = AKEqualizerFilter(input, centerFrequency: 500)
        AKTestMD5("f656c4cfd0054dcb2020339859e1ffe3")
    }

    func testDefault() {
        output = AKEqualizerFilter(input)
        AKTestMD5("7fcd0d089f479c4512fac9d885461702")
    }

    func testGain() {
        output = AKEqualizerFilter(input, gain: 5)
        AKTestMD5("8dfb042339d7a5a6e51885ea199ab9f3")
    }

    func testParameters() {
        output = AKEqualizerFilter(input, centerFrequency: 500, bandwidth: 50, gain: 5)
        AKTestMD5("9248dab9b07bec2957d9c7ce39d22e0c")
    }

}
