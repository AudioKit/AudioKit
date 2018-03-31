//
//  AKHighPassFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKHighPassFilterTests: AKTestCase {

    func testCutoffFrequency() {
        output = AKHighPassFilter(input, cutoffFrequency: 500)
        AKTestMD5("23459f6c63fcb9932f17fc4b2d698e23")
    }

    func testDefault() {
        output = AKHighPassFilter(input)
        AKTestMD5("62cc7c46a46b5dfbc122aeac7c9f6d1d")
    }

    func testParameters() {
        output = AKHighPassFilter(input, cutoffFrequency: 500, resonance: 1)
        AKTestMD5("aec01cf98db93146b8c586c5ac618226")
    }

    func testResonance() {
        output = AKHighPassFilter(input, resonance: 1)
        AKTestMD5("f6a7b41c50a46efbd9ffd20eb294a0af")
    }
}
