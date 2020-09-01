// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKTanhDistortionTests: AKTestCase {

    func testDefault() {
        engine.output = AKTanhDistortion(input)
        AKTest()
    }

    func testNegativeShapeParameter() {
        engine.output = AKTanhDistortion(input, negativeShapeParameter: 1)
        AKTest()
    }

    func testParameters() {
        engine.output = AKTanhDistortion(input, pregain: 4, postgain: 1, positiveShapeParameter: 1, negativeShapeParameter: 1)
        AKTest()
    }

    func testPositiveShapeParameter() {
        engine.output = AKTanhDistortion(input, positiveShapeParameter: 1)
        AKTest()
    }

    func testPostgain() {
        engine.output = AKTanhDistortion(input, postgain: 1)
        AKTest()
    }

    func testPregain() {
        engine.output = AKTanhDistortion(input, pregain: 4)
        AKTest()
    }

}
