// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKPitchShifterTests: AKTestCase2 {

    func testCrossfade() {
        output = AKPitchShifter(input, shift: 7, crossfade: 1_024)
        AKTest()
    }

    func testDefault() {
        output = AKPitchShifter(input)
        AKTest()
    }

    func testParameters() {
        output = AKPitchShifter(input, shift: 7, windowSize: 2_048, crossfade: 1_024)
        AKTest()
    }

    func testShift() {
        output = AKPitchShifter(input, shift: 7)
        AKTest()
    }

    func testWindowSize() {
        output = AKPitchShifter(input, shift: 7, windowSize: 2_048)
        AKTest()
    }

}
