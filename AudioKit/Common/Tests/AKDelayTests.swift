//
//  AKDelayTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKDelayTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKDelay(input)
        input.start()
        AKTestMD5("044cde8ca403d307212887e90925b224")
    }
}
