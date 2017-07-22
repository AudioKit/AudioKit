//
//  AKDCBlockTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKDCBlockTests: AKTestCase {

    func testDefault() {
        output = AKDCBlock(input)
        AKTestMD5("9aa1ca63b47bc690651d5bb24b33c54f")
    }

    func testActuallyProcessing() {
        let input = AKOscillator(waveform: AKTable(.square))
        output = input
        AKTestMD5Not("9aa1ca63b47bc690651d5bb24b33c54f")
    }
}
