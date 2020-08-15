// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKChorusTests: AKTestCase {

    func testParameters() {
        output = AKChorus(input,
                          frequency: 1.1,
                          depth: 0.8,
                          feedback: 0.7,
                          dryWetMix: 0.9)
        AKTestMD5("a63b66759e4bef330b6503254ff76987")
    }

    func testDefault() {
        output = AKChorus(input)
        AKTestMD5("a18ff18d2ca1882f65e9676977e6efaf")
    }

    func testDepth() {
        output = AKChorus(input, depth: 0.88)
        AKTestMD5("b180ff2e652a1113e4f412c3423e302c")
    }

    func testDryWetMix() {
        output = AKChorus(input, dryWetMix: 0.55)
        AKTestMD5("1dce18c51ba885f20b2f2fbdbe5e1cc4")
    }

    func testFeedback() {
        output = AKChorus(input, feedback: 0.77)
        AKTestMD5("82c634aeb34a9a4a048ef0f0b46d0997")
    }

    func testFrequency() {
        output = AKChorus(input, frequency: 1.11)
        AKTestMD5("b07f4ee6d96be2f7f9f65afbfcf2f8df")
    }
}

