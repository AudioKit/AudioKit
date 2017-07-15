//
//  AKClipperTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKClipperTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKClipper(input)
        input.start()
        AKTestMD5("c29feeb240b68c3230dade9346c5b2cd")
    }

    func testParameters1() {
        let input = AKOscillator()
        output = AKClipper(input, limit: 0.1)
        input.start()
        AKTestMD5("78ca0e2e5de5a71b6ab03617be82101d")
    }

    func testParameters2() {
        let input = AKOscillator()
        output = AKClipper(input, limit: 0.5)
        input.start()
        AKTestMD5("082b5cbd01b7e2c2fb660277f9499159")
    }

}
