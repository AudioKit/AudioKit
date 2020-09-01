// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKChorusTests: AKTestCase {

    func testParameters() {
        engine.output = AKChorus(input,
                          frequency: 1.1,
                          depth: 0.8,
                          feedback: 0.7,
                          dryWetMix: 0.9)
        AKTest()
    }

    func testDefault() {
        engine.output = AKChorus(input)
        AKTest()
    }

    func testDepth() {
        engine.output = AKChorus(input, depth: 0.88)
        AKTest()
    }

    func testDryWetMix() {
        engine.output = AKChorus(input, dryWetMix: 0.55)
        AKTest()
    }

    func testFeedback() {
        engine.output = AKChorus(input, feedback: 0.77)
        AKTest()
    }

    func testFrequency() {
        engine.output = AKChorus(input, frequency: 1.11)
        AKTest()
    }
}

