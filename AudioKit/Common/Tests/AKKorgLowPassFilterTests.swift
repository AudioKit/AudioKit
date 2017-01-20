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
        AKTestMD5("7af70e231a5d56dff8b06fbeef921e78")
    }
}
