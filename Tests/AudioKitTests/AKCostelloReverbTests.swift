// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKCostelloReverbTests: AKTestCase2 {

    func testCutoffFrequency() {
        output = AKCostelloReverb2(input, cutoffFrequency: 1_234)
        AKTest()
    }

    func testDefault() {
        output = AKCostelloReverb2(input)
        AKTest()
    }

    func testFeedback() {
        output = AKCostelloReverb2(input, feedback: 0.95)
        AKTest()
    }

    func testParametersSetAfterInit() {
        let effect = AKCostelloReverb2(input)
        effect.rampDuration = 0.0
        effect.cutoffFrequency = 1_234
        effect.feedback = 0.95
        output = effect
        AKTest()
    }

    func testParametersSetOnInit() {
        output = AKCostelloReverb2(input,
                                  feedback: 0.95,
                                  cutoffFrequency: 1_234)
        AKTest()
    }

}
