//
//  AKPeakLimiterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKPeakLimiterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKPeakLimiter(input)
        input.start()
        AKTestMD5("74e37ff4fabffe930b31a2ebc43463dc")
    }
}
