//
//  AKHighPassFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKHighPassFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKHighPassFilter(input)
        input.start()
        AKTestMD5("c424cf5a476a13999080fb9ca86f858f")
    }
}
