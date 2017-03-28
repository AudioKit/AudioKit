//
//  AKHighPassFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKHighPassFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKHighPassFilter(input)
        input.start()
        AKTestMD5("c424cf5a476a13999080fb9ca86f858f")
    }
}
