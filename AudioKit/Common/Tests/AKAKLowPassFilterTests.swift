//
//  AKLowPassFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
@testable import AudioKit

class AKLowPassFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKLowPassFilter(input)
        input.start()
        AKTestMD5("bebc673a689cb7018fb0bb0b48de5f67")
    }
}
