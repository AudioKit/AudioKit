//
//  AKDelayTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKDelayTests: AKTestCase {

    func testDryWetMix() {
        output = AKDelay(input, time: 0.012_3, dryWetMix: 0.456)
        AKTestMD5("ecb2a1a36fe3e396f9295df8f28e6eb0")
    }

    func testFeedback() {
        output = AKDelay(input, time: 0.012_3, feedback: 0.345)
        AKTestMD5("97af0bb6ad8c9b3c6cf0d78215505ebc")
    }

    func testLowpassCutoff() {
        output = AKDelay(input, time: 0.012_3, lowPassCutoff: 1_234)
        AKTestMD5("cc4e9be96f1c5a8b8fc445b7e82de209")
    }

    func testParameters() {
        output = AKDelay(input, time: 0.012_3, feedback: 0.345, lowPassCutoff: 1_234, dryWetMix: 0.456)
        AKTestMD5("d80d89be33aa882b7070ffd13a3a0b43")
    }

    func testTime() {
        output = AKDelay(input, time: 0.012_3)
        AKTestMD5("84cd91433f217ff4a52980a5f6a62431")
    }

}
