// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKTubularBellsTests: AKTestCase2 {

    func testTubularBells() {

        let bells = AKTubularBells()
        bells.trigger(note: 69)
        output = bells

        // auditionTest()
        AKTest()

    }

    func testAmplitude() {

        let bells = AKTubularBells()
        bells.trigger(note: 69, velocity: 64)
        output = bells

        // auditionTest()
        AKTest()

    }

}
