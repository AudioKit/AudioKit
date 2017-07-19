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
        let input = AKOscillator()
        output = AKModalResonanceFilter(input)
        input.start()
        AKTestMD5("9cd15a61ff271c2717bfb42a66e45c00")
    }

    func testParameters() {
        let input = AKOscillator()
        output = AKModalResonanceFilter(input, frequency: 400, qualityFactor: 66)
        input.start()
        AKTestMD5("fbbc4d5d65034860afccece4d69e8e9f")
    }

    func testFrequency() {
        let input = AKOscillator()
        output = AKModalResonanceFilter(input, frequency: 400)
        input.start()
        AKTestMD5("c82b8176ce2048e3f409140a41ab5bea")
    }

    func testQualityFactor() {
        let input = AKOscillator()
        output = AKModalResonanceFilter(input, qualityFactor: 66)
        input.start()
        AKTestMD5("ccf890b181da61f58b545c80d57d8002")
    }
}
