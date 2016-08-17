//
//  AKKorgLowPassFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKKorgLowPassFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKKorgLowPassFilter(input)
        input.start()
        AKTestMD5("d1e2f071287f83dbe547032fe00fec5c")
    }
}
