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
        AKTestMD5("4b5b95ba9f972350ef57fb9f4fe4f83d")
    }
}
