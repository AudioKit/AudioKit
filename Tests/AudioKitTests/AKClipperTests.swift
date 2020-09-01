// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKClipperTests: AKTestCase {

    func testDefault() {
        engine.output = AKClipper(input)
        AKTest()
    }

    func testParameters1() {
        engine.output = AKClipper(input, limit: 0.1)
        AKTest()
    }

    func testParameters2() {
        engine.output = AKClipper(input, limit: 0.5)
        AKTest()
    }

}
