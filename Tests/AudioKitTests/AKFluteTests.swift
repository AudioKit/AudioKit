// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKFluteTests: AKTestCase2 {

    func testFlute() {

        let flute = AKFlute()
        flute.trigger(note: 69)
        output = flute

        // auditionTest()
        AKTest()

    }

    func testVelocity() {

        let flute = AKFlute()
        flute.trigger(note: 69, velocity: 64)
        output = flute

        // auditionTest()
        AKTest()

    }

}
