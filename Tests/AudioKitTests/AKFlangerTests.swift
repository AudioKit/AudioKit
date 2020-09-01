// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKFlangerTests: AKTestCase {

    func testParameters() {
        engine.output = AKFlanger(input,
                          frequency: 1.1,
                          depth: 0.8,
                          feedback: 0.7,
                          dryWetMix: 0.9)
        AKTest()
    }

    func testDefault() {
        engine.output = AKFlanger(input)
        AKTest()
    }

    func testDepth() {
        engine.output = AKFlanger(input, depth: 0.88)
        AKTest()
    }

    func testDryWetMix() {
        engine.output = AKFlanger(input, dryWetMix: 0.55)
        AKTest()
    }

    func testFeedback() {
        engine.output = AKFlanger(input, feedback: 0.77)
        AKTest()
    }

    func testFrequency() {
        engine.output = AKFlanger(input, frequency: 1.11)
        AKTest()
    }


}
