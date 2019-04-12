//
//  reverberateWithFlatFrequencyResponseTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class ReverberateWithFlatFrequencyResponseTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        output = AKOperationEffect(input) { input, _ in
            return input.reverberateWithFlatFrequencyResponse()
        }
        AKTestMD5("81986911704e817a55f6259c3dc94904")
    }

}
