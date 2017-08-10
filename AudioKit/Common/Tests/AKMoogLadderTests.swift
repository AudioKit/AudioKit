//
//  AKMoogLadderTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKMoogLadderTests: AKTestCase {

    func testDefault() {
        output = AKMoogLadder(input)
        AKTestMD5("d35b507249824188ed4907dd5ae243f2")
    }

    func testParameters() {
        output = AKMoogLadder(input, cutoffFrequency: 500, resonance: 0.9)
        AKTestMD5("f7ff6900210175305fc13e1ef56af8ea")
    }

    func testCutoffFrequency() {
        output = AKMoogLadder(input, cutoffFrequency: 500)
        AKTestMD5("7eedd15a6ba4d4cbab4e5aae0a2d9427")
    }

    func testResonance() {
        output = AKMoogLadder(input, resonance: 0.9)
        AKTestMD5("8e7dff73adf308d5fb3540ea59386a63")
    }

}
