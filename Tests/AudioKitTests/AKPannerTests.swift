// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKPannerTests: AKTestCase {

    func testDefault() {
        engine.output = AKPanner(input)
        AKTest()
    }

    func testBypass() {
        let pan = AKPanner(input, pan: -1)
        pan.bypass()
        engine.output = pan
        AKTestNoEffect()
    }

    func testPanLeft() {
        engine.output = AKPanner(input, pan: -1)
        AKTest()
    }

    func testPanRight() {
        engine.output = AKPanner(input, pan: 1)
        AKTest()
    }
}
