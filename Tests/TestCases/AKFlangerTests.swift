// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKFlangerTests: AKTestCase {

    func testParameters() {
        output = AKFlanger(input,
                          frequency: 1.1,
                          depth: 0.8,
                          feedback: 0.7,
                          dryWetMix: 0.9)
        AKTestMD5("dbc08457a2b81e82c0349fa41ff1b800")
    }

    func testDefault() {
        output = AKFlanger(input)
        AKTestMD5("f0694e3aee9be03a6d03dfe4116187c6")
    }

    func testDepth() {
        output = AKFlanger(input, depth: 0.88)
        AKTestMD5("3d6e356c1c1b7a77e308f76f0199f5b6")
    }

    func testDryWetMix() {
        output = AKFlanger(input, dryWetMix: 0.55)
        AKTestMD5("ae90747e83640df07235cb1a06852be3")
    }

    func testFeedback() {
        output = AKFlanger(input, feedback: 0.77)
        AKTestMD5("59c26480d955e8f792ef7a416d3ea227")
    }

    func testFrequency() {
        output = AKFlanger(input, frequency: 1.11)
        AKTestMD5("df843a1dad2d3ba0b1dd51711ab5bada")
    }


}
