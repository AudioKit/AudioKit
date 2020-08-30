// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKChorusTests: AKTestCase2 {

    func testParameters() {
        output = AKChorus(input,
                          frequency: 1.1,
                          depth: 0.8,
                          feedback: 0.7,
                          dryWetMix: 0.9)
        AKTest()
    }

    func testDefault() {
        output = AKChorus(input)
        AKTest()
    }

    func testDepth() {
        output = AKChorus(input, depth: 0.88)
        AKTest()
    }

    func testDryWetMix() {
        output = AKChorus(input, dryWetMix: 0.55)
        AKTest()
    }

    func testFeedback() {
        output = AKChorus(input, feedback: 0.77)
        AKTest()
    }

    func testFrequency() {
        output = AKChorus(input, frequency: 1.11)
        AKTest()
    }
}

