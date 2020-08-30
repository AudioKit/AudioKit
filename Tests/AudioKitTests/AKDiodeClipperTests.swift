// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKDiodeClipperTests: AKTestCase2 {

    func testDefault() {
        output = AKDiodeClipper(input)
        AKTest()
    }

    func testParameters1() {
        output = AKDiodeClipper(input, cutoffFrequency: 1000, gain: 1.0)
        AKTest()
    }

    func testParameters2() {
        output = AKDiodeClipper(input, cutoffFrequency: 2000, gain: 2.0)
        AKTest()
    }

}
