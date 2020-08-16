// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKMandolinStringTests: AKTestCase {

    func testMandolin() {

        let mandolin = AKMandolinString()
        mandolin.trigger(note: 69)
        output = mandolin

        // auditionTest()
        AKTestMD5("2e192fd0c660a517e6fe1daefd639521")

    }

    func testAmplitude() {

        let mandolin = AKMandolinString()
        mandolin.trigger(note: 69, velocity: 64)
        output = mandolin

        // auditionTest()
        AKTestMD5("a7f9870da8e9b9aad6af57ad8ac2503f")

    }

}
