// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKFluteTests: AKTestCase {

    func testFlute() {

        let flute = AKFlute()
        flute.trigger(note: 69)
        output = flute

        // auditionTest()
        AKTestMD5("f7fd94da1321d1727af4d12d6355437c")

    }

    func testAmplitude() {

        let flute = AKFlute()
        flute.trigger(note: 69, amplitude: 0.5)
        output = flute

        // auditionTest()
        AKTestMD5("6d2f0919321285777c8028bc4902e262")

    }

}
