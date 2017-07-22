//
//  AKRolandTB303FilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKRolandTB303FilterTests: AKTestCase {

    func testDefault() {
        output = AKRolandTB303Filter(input)
        AKTestMD5("0f8345a5be46169f37d5650dc01f8ffa")
    }

    func testParameters() {
        output = AKRolandTB303Filter(input,
                                     cutoffFrequency: 400,
                                     resonance: 1,
                                     distortion: 1,
                                     resonanceAsymmetry: 0.66)
        AKTestMD5("06cf058d7132f973361ec9c22bab11ce")
    }

    func testCutoffFrequency() {
        output = AKRolandTB303Filter(input, cutoffFrequency: 400)
        AKTestMD5("a67a0ae2773ed3126f59c911342860be")
    }

    func testResonance() {
        output = AKRolandTB303Filter(input, resonance: 1)
        AKTestMD5("c456837d4c82e7f0d43aeb0ada75a86d")
    }

    func testDistortion() {
        output = AKRolandTB303Filter(input, distortion: 1)
        AKTestMD5("efb5123eaa7b760c5e220fefd0ae45a2")
    }

    func testResonanceAsymmetry() {
        output = AKRolandTB303Filter(input, resonanceAsymmetry: 0.66)
        AKTestMD5("5fd76c6ec136770c7402119a3eef8ebf")
    }
}
