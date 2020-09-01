// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit
import CAudioKit

class AKClarinetTest: AKTestCase {

    func testClarinet() {

        akSetSeed(0)

        let clarinet = AKClarinet()
        clarinet.trigger(note: 69)
        engine.output = clarinet

        AKTest()
    }

    func testVelocity() {

        akSetSeed(0)

        let clarinet = AKClarinet()
        clarinet.trigger(note: 69, velocity: 64)
        engine.output = clarinet

        AKTest()
    }

}
