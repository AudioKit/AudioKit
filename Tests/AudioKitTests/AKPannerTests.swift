// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKPannerTests: AKTestCase2 {

    func testDefault() {
        output = AKPanner(input)
        AKTest()
    }

    func testBypass() {
        let pan = AKPanner(input, pan: -1)
        pan.bypass()
        output = pan
        AKTestNoEffect()
    }

    func testPanLeft() {
        output = AKPanner(input, pan: -1)
        AKTest()
    }

    func testPanRight() {
        output = AKPanner(input, pan: 1)
        AKTest()
    }
}
