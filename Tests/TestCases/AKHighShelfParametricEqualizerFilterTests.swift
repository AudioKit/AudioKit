//
//  AKHighShelfParametricEqualizerFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKHighShelfParametricEqualizerFilterTests: AKTestCase {

    func testCenterFrequency() {
        output = AKHighShelfParametricEqualizerFilter(input, centerFrequency: 500)
        AKTestMD5("7740ecbdab1d4603e4735967ef6c5826")
    }

    func testDefault() {
        output = AKHighShelfParametricEqualizerFilter(input)
        AKTestMD5("a96e1c906e49e0624a4526214ae39d4f")
    }

    func testGain() {
        output = AKHighShelfParametricEqualizerFilter(input, gain: 2)
        AKTestMD5("1b26bf87fc0e3f966e563e8620a89035")
    }

    func testParameters() {
        output = AKHighShelfParametricEqualizerFilter(input, centerFrequency: 500, gain: 2, q: 1.414)
        AKTestMD5("37d9d6a652d5f3005cc72a016346320e")
    }

    func testQ() {
        output = AKHighShelfParametricEqualizerFilter(input, q: 1.415)
        AKTestMD5("7129dc22105d3525c277d08e8b397667")
    }
}
