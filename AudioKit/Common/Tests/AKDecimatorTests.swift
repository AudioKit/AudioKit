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
        AKTestMD5("6cfdce459c60b32a796383335ae167d7")
    }

    func testParameters() {
        let input = AKOscillator()
        output = AKDecimator(input, decimation: 0.75, rounding: 0.5, mix: 0.5)
        input.start()
        AKTestMD5("7bd8ec15e201a0be6962e633039a05bc")
    }
}
