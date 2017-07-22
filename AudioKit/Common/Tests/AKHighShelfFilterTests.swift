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
        output = AKHighShelfFilter(input)
        AKTestNoEffect()
    }

    func testParameters() {
        output = AKHighShelfFilter(input, cutOffFrequency: 400, gain: 1)
        AKTestMD5("b860cd338fa99916dee27a8adbb541d0")
    }

    func testGain() {
        output = AKHighShelfFilter(input, gain: 1)
        AKTestMD5("837229cb7cc816321f61c76b90312bce")
    }
}
