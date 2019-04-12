//
//  AKFormantFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKFormantFilterTests: AKTestCase {

    func testAttack() {
        output = AKFormantFilter(input, attackDuration: 0.023_4)
        AKTestMD5("5f72212ff42b9803edf31a316147db2b")
    }

    func testCenterFrequency() {
        output = AKFormantFilter(input, centerFrequency: 500)
        AKTestMD5("1b9e3e8a98cbb94692229353ace5de93")
    }

    func testDecay() {
        output = AKFormantFilter(input, decayDuration: 0.023_4)
        AKTestMD5("1da8ef2b30a19d88239d308603d19d93")
    }

    func testDefault() {
        output = AKFormantFilter(input)
        AKTestMD5("108af8dc8247857aa4bbcb76881d9a70")
    }
}
