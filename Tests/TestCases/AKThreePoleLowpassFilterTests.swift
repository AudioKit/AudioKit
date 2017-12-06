//
//  AKThreePoleLowpassFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKThreePoleLowpassFilterTests: AKTestCase {

    func testCutoffFrequency() {
        output = AKThreePoleLowpassFilter(input, cutoffFrequency: 500)
        AKTestMD5("ec26496e6ee4da9945fd4f2c2df9d6a1")
    }

    func testDefault() {
        output = AKThreePoleLowpassFilter(input)
        AKTestMD5("787ed3c7631adee9af6bd9603a6a7e56")
    }

    func testDistortion() {
        output = AKThreePoleLowpassFilter(input, distortion: 1)
        AKTestMD5("39e2f904606600640b5b83a680457c2b")
    }

    func testParameters() {
        output = AKThreePoleLowpassFilter(input, distortion: 1, cutoffFrequency: 500, resonance: 1)
        AKTestMD5("15a8a9a91615e0c1f72f3b83e3526729")
    }

    func testResonance() {
        output = AKThreePoleLowpassFilter(input, resonance: 1)
        AKTestMD5("98ad6f5f4327410317ec4e277ee5cf2c")
    }
}
