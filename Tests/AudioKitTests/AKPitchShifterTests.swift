// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKPitchShifterTests: AKTestCase {

    func testCrossfade() {
        engine.output = AKPitchShifter(input, shift: 7, crossfade: 1_024)
        AKTest()
    }

    func testDefault() {
        engine.output = AKPitchShifter(input)
        AKTest()
    }

    func testParameters() {
        engine.output = AKPitchShifter(input, shift: 7, windowSize: 2_048, crossfade: 1_024)
        AKTest()
    }

    func testShift() {
        engine.output = AKPitchShifter(input, shift: 7)
        AKTest()
    }

    func testWindowSize() {
        engine.output = AKPitchShifter(input, shift: 7, windowSize: 2_048)
        AKTest()
    }

}
