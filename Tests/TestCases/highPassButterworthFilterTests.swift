//
//  highPassButterworthFilterTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class HighPassButterworthFilterTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        output = AKOperationEffect(input) { input, _ in
            return input.highPassButterworthFilter()
        }
        AKTestMD5("858d7618e2dcb1eeabacb70a4d183c5d")
    }

}
