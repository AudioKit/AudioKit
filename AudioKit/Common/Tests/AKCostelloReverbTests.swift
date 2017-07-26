//
//  AKCostelloReverbTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKCostelloReverbTests: AKTestCase {

    func testDefault() {
        output = AKCostelloReverb(input)
        AKTestMD5("369cf95067da35910aae0c65a4b81eb7")
    }

    func testParametersSetOnInit() {
        output = AKCostelloReverb(input,
                                  feedback: 0.95,
                                  cutoffFrequency: 1_234)
        AKTestMD5("4ac9c83b90ce86327198c3c428bf6922")
    }

    func testParametersSetAfterInit() {
        let effect = AKCostelloReverb(input)
        effect.cutoffFrequency = 1_234
        effect.feedback = 0.95
        output = effect
        AKTestMD5("4ac9c83b90ce86327198c3c428bf6922")
    }

    func testFeedback() {
        output = AKCostelloReverb(input, feedback: 0.95)
        AKTestMD5("60d1654aa643afa53fee3206a883161a")
    }

    func testCutoffFrequency() {
        output = AKCostelloReverb(input, cutoffFrequency: 1_234)
        AKTestMD5("8d9e94a397d793d2a26d73d8a9dab970")
    }
}
