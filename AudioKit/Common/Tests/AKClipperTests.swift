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
        output = AKClipper(input)
        AKTestMD5("c29feeb240b68c3230dade9346c5b2cd")
    }

    func testParameters1() {
        output = AKClipper(input, limit: 0.1)
        AKTestMD5("78ca0e2e5de5a71b6ab03617be82101d")
    }

    func testParameters2() {
        output = AKClipper(input, limit: 0.5)
        AKTestMD5("082b5cbd01b7e2c2fb660277f9499159")
    }

}
