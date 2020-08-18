// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit
import CAudioKit

class AKClarinetTest: AKTestCase {

    func testClarinet() {

        akSetSeed(0)

        let clarinet = AKClarinet()
        clarinet.trigger(note: 69)
        output = clarinet

        // auditionTest()
        AKTestMD5("0ff85d140be73b31ad2639e7cbddec5a")
    }

    func testVelocity() {

        akSetSeed(0)

        let clarinet = AKClarinet()
        clarinet.trigger(note: 69, velocity: 64)
        output = clarinet

        // auditionTest()
        AKTestMD5("dd21424f2848b399b393d4f5b0308680")
    }

}
