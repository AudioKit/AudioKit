//
//  AKBandRejectButterworthFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKBandRejectButterworthFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKBandRejectButterworthFilter(input)
        input.start()
        AKTestMD5("1867f535fbd070464c14cb2f6bc94f09")
    }
}
