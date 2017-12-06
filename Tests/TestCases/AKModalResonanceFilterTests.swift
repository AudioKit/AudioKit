//
//  AKModalResonanceFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKModalResonanceFilterTests: AKTestCase {

    func testDefault() {
        output = AKModalResonanceFilter(input)
        AKTestMD5("a1c79cc21bc560f9f26916487ae02200")
    }

    func testFrequency() {
        output = AKModalResonanceFilter(input, frequency: 400)
        AKTestMD5("f6c0279cfe06bcdc15a02dd28cfa8c81")
    }

    func testParameters() {
        output = AKModalResonanceFilter(input, frequency: 400, qualityFactor: 66)
        AKTestMD5("07c70068366c99c3c5a3d32d32a1d72b")
    }

    func testQualityFactor() {
        output = AKModalResonanceFilter(input, qualityFactor: 66)
        AKTestMD5("54657c12325b2633079164fb99582c90")
    }
}
