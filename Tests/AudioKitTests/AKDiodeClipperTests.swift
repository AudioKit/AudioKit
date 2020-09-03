// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKDiodeClipperTests: AKTestCase {

    func testDefault() {
        engine.output = AKDiodeClipper(input)
        AKTest()
    }

    func testParameters1() {
        engine.output = AKDiodeClipper(input, cutoffFrequency: 1000, gain: 1.0)
        AKTest()
    }

    func testParameters2() {
        engine.output = AKDiodeClipper(input, cutoffFrequency: 2000, gain: 2.0)
        AKTest()
    }

}
