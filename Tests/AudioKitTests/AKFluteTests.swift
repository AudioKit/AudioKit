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

    func testVelocity() {

        let flute = AKFlute()
        flute.trigger(note: 69, velocity: 64)
        output = flute

        // auditionTest()
        AKTestMD5("cee2cf38e1ea64300dc81158988c4a9d")

    }

}
