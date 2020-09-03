// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKMandolinStringTests: AKTestCase {

    func testMandolin() {

        let mandolin = AKMandolinString()
        mandolin.trigger(note: 69)
        engine.output = mandolin

        AKTest()

    }

    func testAmplitude() {

        let mandolin = AKMandolinString()
        mandolin.trigger(note: 69, velocity: 64)
        engine.output = mandolin

        AKTest()

    }

}
