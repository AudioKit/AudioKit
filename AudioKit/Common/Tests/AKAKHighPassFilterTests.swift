//
//  AKHighPassFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
@testable import AudioKit

class AKHighPassFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKHighPassFilter(input)
        input.start()
        AKTestMD5("3303c5eafd1fb21185459a420b344ab4")
    }
}
