// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit
import CAudioKit

class AKClarinetTest: AKTestCase2 {

    func testClarinet() {

        akSetSeed(0)

        let clarinet = AKClarinet()
        clarinet.trigger(note: 69)
        output = clarinet

        // auditionTest()
        AKTest()
    }

    func testVelocity() {

        akSetSeed(0)

        let clarinet = AKClarinet()
        clarinet.trigger(note: 69, velocity: 64)
        output = clarinet

        // auditionTest()
        AKTest()
    }

}
