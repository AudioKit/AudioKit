// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKTanhDistortionTests: AKTestCase {

    func testDefault() {
        output = AKTanhDistortion(input)
        AKTest()
    }

    func testNegativeShapeParameter() {
        output = AKTanhDistortion(input, negativeShapeParameter: 1)
        AKTest()
    }

    func testParameters() {
        output = AKTanhDistortion(input, pregain: 4, postgain: 1, positiveShapeParameter: 1, negativeShapeParameter: 1)
        AKTest()
    }

    func testPositiveShapeParameter() {
        output = AKTanhDistortion(input, positiveShapeParameter: 1)
        AKTest()
    }

    func testPostgain() {
        output = AKTanhDistortion(input, postgain: 1)
        AKTest()
    }

    func testPregain() {
        output = AKTanhDistortion(input, pregain: 4)
        AKTest()
    }

}
