//
//  AKResonantFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKResonantFilterTests: AKTestCase {

    func testBandwidth() {
        output = AKResonantFilter(input, bandwidth: 500)
        AKTestMD5("1ce762dcc6610747f580d010636d4752")
    }

    func testDefault() {
        output = AKResonantFilter(input)
        AKTestMD5("1b4298186c1980cb38cbe1b7a11b56f0")
    }

    func testFrequency() {
        output = AKResonantFilter(input, frequency: 1_000)
        AKTestMD5("3fb324974ecfe525fbf4bcf2ac303ff9")
    }

    func testParameters() {
        output = AKResonantFilter(input, frequency: 1_000, bandwidth: 500)
        AKTestMD5("294c083b6980ee6c63c2b83e55f89d9d")
    }

}
