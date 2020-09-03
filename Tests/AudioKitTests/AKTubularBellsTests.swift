// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKTubularBellsTests: AKTestCase {

    func testTubularBells() {

        let bells = AKTubularBells()
        bells.trigger(note: 69)
        engine.output = bells

        AKTest()

    }

    func testAmplitude() {

        let bells = AKTubularBells()
        bells.trigger(note: 69, velocity: 64)
        engine.output = bells

        AKTest()

    }

}
