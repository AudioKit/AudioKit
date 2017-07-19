//
//  AKHighShelfFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKHighShelfFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKHighShelfFilter(input)
        input.start()
        AKTestNoEffect()
    }

    func testParameters() {
        let input = AKOscillator()
        output = AKHighShelfFilter(input, cutOffFrequency: 400, gain: 1)
        input.start()
        AKTestMD5("b860cd338fa99916dee27a8adbb541d0")
    }

    func testGain() {
        let input = AKOscillator()
        output = AKHighShelfFilter(input, gain: 1)
        input.start()
        AKTestMD5("837229cb7cc816321f61c76b90312bce")
    }
}
