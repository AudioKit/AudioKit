//
//  AKLowShelfParametricEqualizerFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKLowShelfParametricEqualizerFilterTests: AKTestCase {

    func testCornerFrequency() {
        output = AKLowShelfParametricEqualizerFilter(input, cornerFrequency: 500)
        AKTestMD5("840f10822bf080a52e1b5a9b9fe7d766")
    }

    func testDefault() {
        output = AKLowShelfParametricEqualizerFilter(input)
        AKTestMD5("946b5151d61b571cc4c4aa50e05683e4")
    }

    func testGain() {
        output = AKLowShelfParametricEqualizerFilter(input, gain: 2)
        AKTestMD5("b174d2830cc74bf2424992aaecee08cc")
    }

    func testParameters() {
        output = AKLowShelfParametricEqualizerFilter(input, cornerFrequency: 500, gain: 2, q: 1.414)
        AKTestMD5("c8a5001e857c84d73a740bf3a922fa08")
    }

    func testQ() {
        output = AKLowShelfParametricEqualizerFilter(input, q: 1.415)
        AKTestMD5("b2a998b3183f238770df05bec367d162")
    }
}
