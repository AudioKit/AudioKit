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

    func testCutoffFrequency() {
        output = AKRolandTB303Filter(input, cutoffFrequency: 400)
        AKTestMD5("4e4d3d1d59c1e27de3c3b7f19a2ba749")
    }

    func testDefault() {
        output = AKRolandTB303Filter(input)
        AKTestMD5("a03ff20770be1844d163d6ae7288bc19")
    }

    func testDistortion() {
        output = AKRolandTB303Filter(input, distortion: 1)
        AKTestMD5("f8be86a128671bb0351e1a10e06c0776")
    }

    func testParameters() {
        output = AKRolandTB303Filter(input,
                                     cutoffFrequency: 400,
                                     resonance: 1,
                                     distortion: 1,
                                     resonanceAsymmetry: 0.66)
        AKTestMD5("46fb509f4d44addb5fca8ac00c51daeb")
    }

    func testResonance() {
        output = AKRolandTB303Filter(input, resonance: 1)
        AKTestMD5("88188ae732ef35b5d729b35bd2ce57c9")
    }

    func testResonanceAsymmetry() {
        output = AKRolandTB303Filter(input, resonanceAsymmetry: 0.66)
        AKTestMD5("e6bd521da1b764c710075c9f1368ff74")
    }
}
