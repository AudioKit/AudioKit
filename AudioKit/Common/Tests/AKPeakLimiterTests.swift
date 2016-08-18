//
//  AKPeakLimiterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKPeakLimiterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKPeakLimiter(input)
        input.start()
        AKTestMD5("325d340c8085aa5232f17c0398a1cdfb")
    }
}
