//
//  AKLowShelfParametricEqualizerFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKLowShelfParametricEqualizerFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKLowShelfParametricEqualizerFilter(input)
        input.start()
        AKTestMD5("56c1b9e1b8509124b8365b707fb05321")
    }

    func testParameters() {
        let input = AKOscillator()
        output = AKLowShelfParametricEqualizerFilter(input, cornerFrequency: 500, gain: 2, q: 1.414)
        input.start()
        AKTestMD5("188f35800f69ff0b56563814b3856960")
    }

    func testCornerFrequency() {
        let input = AKOscillator()
        output = AKLowShelfParametricEqualizerFilter(input, cornerFrequency: 500)
        input.start()
        AKTestMD5("7a4644b6afd5e00ee30f2ff22c12cf00")
    }

    func testGain() {
        let input = AKOscillator()
        output = AKLowShelfParametricEqualizerFilter(input, gain: 2)
        input.start()
        AKTestMD5("676c10e0a34ca31673fd1fc84a391aff")
    }

    func testQ() {
        let input = AKOscillator()
        output = AKLowShelfParametricEqualizerFilter(input, q: 1.415)
        input.start()
        AKTestMD5("c23dea51ff8e11c68d8a81bb39c34604")
    }
}
