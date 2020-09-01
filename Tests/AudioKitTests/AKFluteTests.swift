// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKFluteTests: AKTestCase {

    func testFlute() {

        let flute = AKFlute()
        flute.trigger(note: 69)
        engine.output = flute

        AKTest()

    }

    func testVelocity() {

        let flute = AKFlute()
        flute.trigger(note: 69, velocity: 64)
        engine.output = flute

        AKTest()

    }

}
