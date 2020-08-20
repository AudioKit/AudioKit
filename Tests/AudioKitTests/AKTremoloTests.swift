// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKTremoloTests: AKTestCase {

    func testDefault() {
        output = AKTremolo(input)
        AKTest()
    }

    func testDepth() {
        output = AKTremolo(input, depth: 0.5)
        AKTest()
    }

    func testFrequency() {
        output = AKTremolo(input, frequency: 20)
        AKTest()
    }

    func testParameters() {
        output = AKTremolo(input, frequency: 20, depth: 0.5)
        AKTest()
    }

}
