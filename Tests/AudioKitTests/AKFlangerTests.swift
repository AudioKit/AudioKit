// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKFlangerTests: AKTestCase2 {

    func testParameters() {
        output = AKFlanger(input,
                          frequency: 1.1,
                          depth: 0.8,
                          feedback: 0.7,
                          dryWetMix: 0.9)
        AKTest()
    }

    func testDefault() {
        output = AKFlanger(input)
        AKTest()
    }

    func testDepth() {
        output = AKFlanger(input, depth: 0.88)
        AKTest()
    }

    func testDryWetMix() {
        output = AKFlanger(input, dryWetMix: 0.55)
        AKTest()
    }

    func testFeedback() {
        output = AKFlanger(input, feedback: 0.77)
        AKTest()
    }

    func testFrequency() {
        output = AKFlanger(input, frequency: 1.11)
        AKTest()
    }


}
