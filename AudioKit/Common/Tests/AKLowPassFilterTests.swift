//
//  AKLowPassFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKLowPassFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKLowPassFilter(input)
        input.start()
        AKTestMD5("29e845d8432f07261d09f7e5edc29445")
    }
}
