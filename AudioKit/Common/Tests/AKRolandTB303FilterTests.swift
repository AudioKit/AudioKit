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
        let input = AKOscillator()
        output = AKRolandTB303Filter(input)
        input.start()
        AKTestMD5("0f8345a5be46169f37d5650dc01f8ffa")
    }

    func testParameters() {
        let input = AKOscillator()
        output = AKRolandTB303Filter(input,
                                     cutoffFrequency: 400,
                                     resonance: 1,
                                     distortion: 1,
                                     resonanceAsymmetry: 0.66)
        input.start()
        AKTestMD5("06cf058d7132f973361ec9c22bab11ce")
    }

    func testCutoffFrequency() {
        let input = AKOscillator()
        output = AKRolandTB303Filter(input, cutoffFrequency: 400)
        input.start()
        AKTestMD5("a67a0ae2773ed3126f59c911342860be")
    }

    func testResonance() {
        let input = AKOscillator()
        output = AKRolandTB303Filter(input, resonance: 1)
        input.start()
        AKTestMD5("c456837d4c82e7f0d43aeb0ada75a86d")
    }

    func testDistortion() {
        let input = AKOscillator()
        output = AKRolandTB303Filter(input, distortion: 1)
        input.start()
        AKTestMD5("efb5123eaa7b760c5e220fefd0ae45a2")
    }

    func testResonanceAsymmetry() {
        let input = AKOscillator()
        output = AKRolandTB303Filter(input, resonanceAsymmetry: 0.66)
        input.start()
        AKTestMD5("5fd76c6ec136770c7402119a3eef8ebf")
    }
}
