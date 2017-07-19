//
//  AKLowPassFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKLowPassFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKLowPassFilter(input)
        input.start()
        AKTestMD5("29e845d8432f07261d09f7e5edc29445")
    }

    func testParameters() {
        let input = AKOscillator()
        output = AKLowPassFilter(input, cutoffFrequency: 500, resonance: 1)
        input.start()
        AKTestMD5("d51eb0d976c88863d1a2a74025c77d93")
    }

    func testCutoffFrequency() {
        let input = AKOscillator()
        output = AKLowPassFilter(input, cutoffFrequency: 500)
        input.start()
        AKTestMD5("59accce48832ffd39fb1fd027fe23bf7")
    }

    func testResonance() {
        let input = AKOscillator()
        output = AKLowPassFilter(input, resonance: 1)
        input.start()
        AKTestMD5("9fb1c2faf599f2de7fa80b86d23b8c12")
    }
}
