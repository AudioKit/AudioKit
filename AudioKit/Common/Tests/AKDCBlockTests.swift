//
//  AKDCBlockTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKDCBlockTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKDCBlock(input)
        input.start()
        AKTestMD5("9aa1ca63b47bc690651d5bb24b33c54f")
    }
}
