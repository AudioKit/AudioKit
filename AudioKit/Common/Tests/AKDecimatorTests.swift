//
//  AKDecimatorTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKDecimatorTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKDecimator(input)
        input.start()
        AKTestMD5("6b8ce6b9f8ca2a948c46467cfb4a7327")
    }
}
