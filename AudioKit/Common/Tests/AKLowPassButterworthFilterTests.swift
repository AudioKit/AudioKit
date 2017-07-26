//
//  AKLowPassButterworthFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKLowPassButterworthFilterTests: AKTestCase {

    func testDefault() {
        output = AKLowPassButterworthFilter(input)
        AKTestMD5("7d0ddc9ba1d709b22244737b17eafadb")
    }

    func testCutoffFrequency() {
        output = AKLowPassButterworthFilter(input, cutoffFrequency: 500)
        AKTestMD5("1591bbcb5064ee70db40b8286435a424")
    }
}
