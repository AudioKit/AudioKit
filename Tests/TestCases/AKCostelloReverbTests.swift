//
//  AKCostelloReverbTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKCostelloReverbTests: AKTestCase {

    func testCutoffFrequency() {
        output = AKCostelloReverb(input, cutoffFrequency: 1_234)
        AKTestMD5("08e2b24e7fe92c33490d47b796192ef2")
    }

    func testDefault() {
        output = AKCostelloReverb(input)
        AKTestMD5("f886152c9b97ae66e42d3d5d9c821fc2")
    }

    func testFeedback() {
        output = AKCostelloReverb(input, feedback: 0.95)
        AKTestMD5("c8b8fa22214adcfd6ea28ef3d5403c78")
    }

    let commonMD5 = "e0a028d0b2118a3b4e96d04c1bbf08e3"

    func testParametersSetAfterInit() {
        let effect = AKCostelloReverb(input)
        effect.rampDuration = 0.0
        effect.cutoffFrequency = 1_234
        effect.feedback = 0.95
        output = effect
        AKTestMD5(commonMD5)
    }

    func testParametersSetOnInit() {
        output = AKCostelloReverb(input,
                                  feedback: 0.95,
                                  cutoffFrequency: 1_234)
        AKTestMD5(commonMD5)
    }

}
