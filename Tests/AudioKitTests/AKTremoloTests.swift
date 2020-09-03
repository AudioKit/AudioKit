// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKTremoloTests: AKTestCase {

    func testDefault() {
        engine.output = AKTremolo(input)
        AKTest()
    }

    func testDepth() {
        engine.output = AKTremolo(input, depth: 0.5)
        AKTest()
    }

    func testFrequency() {
        engine.output = AKTremolo(input, frequency: 20)
        AKTest()
    }

    func testParameters() {
        engine.output = AKTremolo(input, frequency: 20, depth: 0.5)
        AKTest()
    }

}
