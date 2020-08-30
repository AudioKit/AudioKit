// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKMandolinStringTests: AKTestCase2 {

    func testMandolin() {

        let mandolin = AKMandolinString()
        mandolin.trigger(note: 69)
        output = mandolin

        // auditionTest()
        AKTest()

    }

    func testAmplitude() {

        let mandolin = AKMandolinString()
        mandolin.trigger(note: 69, velocity: 64)
        output = mandolin

        // auditionTest()
        AKTest()

    }

}
