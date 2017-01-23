//
//  AKLowPassButterworthFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKLowPassButterworthFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKLowPassButterworthFilter(input)
        input.start()
        AKTestMD5("84f695a214693116f31fa9d0a8c7352a")
    }
}
