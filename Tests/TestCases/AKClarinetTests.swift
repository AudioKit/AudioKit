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
        AKTestMD5("0ff85d140be73b31ad2639e7cbddec5a")
    }

    func testClarinetFrequency() {

        akSetSeed(0)

        let clarinet = AKClarinet()
        clarinet.frequency = 220
        clarinet.trigger()

        output = clarinet

        // auditionTest()
        AKTestMD5("0ff85d140be73b31ad2639e7cbddec5a")
    }

    func testClarinetAmplitude() {

        akSetSeed(0)

        let clarinet = AKClarinet()
        clarinet.amplitude = 0.5
        clarinet.trigger()
        output = clarinet

        // auditionTest()
        AKTestMD5("0ff85d140be73b31ad2639e7cbddec5a")
    }

}
