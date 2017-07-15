//
//  AKDecimatorTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKDecimatorTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKDecimator(input)
        input.start()
        AKTestMD5("06415139391aca488441c521aea09726")
    }

    func testParameters() {
        let input = AKOscillator()
        output = AKDecimator(input, decimation: 0.75, rounding: 0.5, mix: 0.5)
        input.start()
        AKTestMD5("b1f53c4d7e4040362baf457352d3e6f4")
    }
}
