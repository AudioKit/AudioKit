// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit

class AKClarinetTest: AKTestCase {

    func testClarinet() {

        akSetSeed(0)

        let clarinet = AKClarinet(frequency: 440, amplitude: 1)
        clarinet.trigger()
        output = clarinet

        // auditionTest()
        AKTestMD5("5ab7eb506d9dca36d3b402221031556a")
    }

    func testClarinetFrequency() {

        akSetSeed(0)

        let clarinet = AKClarinet()
        clarinet.frequency = 220
        clarinet.trigger()

        output = clarinet

        // auditionTest()
        AKTestMD5("a3d469e11dfcb0e7210318785524e53e")
    }

    func testClarinetAmplitude() {

        akSetSeed(0)

        let clarinet = AKClarinet()
        clarinet.amplitude = 0.5
        clarinet.trigger()
        output = clarinet

        // auditionTest()
        AKTestMD5("d45b068983c2e0fe391519bf0b0f419c")
    }

}
