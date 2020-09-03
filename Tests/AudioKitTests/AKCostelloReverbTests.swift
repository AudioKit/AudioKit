// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKCostelloReverbTests: AKTestCase {

    func testCutoffFrequency() {
        engine.output = AKCostelloReverb(input, cutoffFrequency: 1_234)
        AKTest()
    }

    func testDefault() {
        engine.output = AKCostelloReverb(input)
        AKTest()
    }

    func testFeedback() {
        engine.output = AKCostelloReverb(input, feedback: 0.95)
        AKTest()
    }

    func testParametersSetAfterInit() {
        let effect = AKCostelloReverb(input)
        effect.rampDuration = 0.0
        effect.cutoffFrequency = 1_234
        effect.feedback = 0.95
        engine.output = effect
        AKTest()
    }

    func testParametersSetOnInit() {
        engine.output = AKCostelloReverb(input,
                                  feedback: 0.95,
                                  cutoffFrequency: 1_234)
        AKTest()
    }

}
