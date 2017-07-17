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
        let input = AKOscillator()
        output = AKCostelloReverb(input)
        input.start()
        AKTestMD5("369cf95067da35910aae0c65a4b81eb7")
    }

    func testParametersSetOnInit() {
        let input = AKOscillator()
        output = AKCostelloReverb(input,
                                  feedback: 0.95,
                                  cutoffFrequency: 1_234)
        input.start()
        AKTestMD5("4ac9c83b90ce86327198c3c428bf6922")
    }

    func testParametersSetAfterInit() {
        let input = AKOscillator()
        let effect = AKCostelloReverb(input)
        effect.cutoffFrequency = 1_234
        effect.feedback = 0.95
        output = effect
        input.start()
        AKTestMD5("4ac9c83b90ce86327198c3c428bf6922")
    }

    func testFeedback() {
        let input = AKOscillator()
        output = AKCostelloReverb(input, feedback: 0.95)
        input.start()
        AKTestMD5("60d1654aa643afa53fee3206a883161a")
    }

    func testCutoffFrequency() {
        let input = AKOscillator()
        output = AKCostelloReverb(input, cutoffFrequency: 1_234)
        input.start()
        AKTestMD5("8d9e94a397d793d2a26d73d8a9dab970")
    }
}
