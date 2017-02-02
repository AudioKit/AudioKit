//
//  AKToneFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKToneFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKToneFilter(input)
        input.start()
        AKTestMD5("4f3b1309e39beed48f9e6b9bff0c401c")
    }
}
