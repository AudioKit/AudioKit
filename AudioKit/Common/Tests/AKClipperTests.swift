//
//  AKClipperTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKClipperTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKClipper(input)
        input.start()
        AKTestMD5("ddb51d47536626c47f8f5254c4733953")
    }
}
