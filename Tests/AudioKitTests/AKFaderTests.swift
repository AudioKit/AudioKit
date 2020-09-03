// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKFaderTests: AKTestCase {

    func testDefault() {
        engine.output = AKFader(input, gain: 1.0)
        AKTestNoEffect()
    }

    func testBypass() {
        let fader = AKFader(input, gain: 2.0)
        fader.bypass()
        engine.output = fader
        AKTestNoEffect()
    }

    func testMany() {
        let initialFader = AKFader(input, gain: 1.0)
        var nextFader = initialFader
        for _ in 0 ..< 200 {
            let fader = AKFader(nextFader, gain: 1.0)
            nextFader = fader
        }
        engine.output = nextFader
        AKTestNoEffect()
    }

    func testFlipStereo() {
        let pan = AKPanner(input, pan: 1.0)
        let fader = AKFader(pan, gain: 1.0)
        fader.flipStereo = true
        engine.output = fader
        AKTest()
    }

    func testFlipStereoTwice() {
        let pan = AKPanner(input, pan: 1.0)
        let fader = AKFader(pan, gain: 1.0)
        fader.flipStereo = true
        let fader2 = AKFader(fader, gain: 1.0)
        fader2.flipStereo = true
        engine.output = fader2
        AKTest()
    }

    func testFlipStereoThrice() {
        let pan = AKPanner(input, pan: 1.0)
        let fader = AKFader(pan, gain: 1.0)
        fader.flipStereo = true
        let fader2 = AKFader(fader, gain: 1.0)
        fader2.flipStereo = true
        let fader3 = AKFader(fader2, gain: 1.0)
        fader3.flipStereo = true
        engine.output = fader3
        AKTest()
    }

    func testMixToMono() {
        let pan = AKPanner(input, pan: 1.0)
        let fader = AKFader(pan, gain: 1.0)
        fader.mixToMono = true
        engine.output = fader
        AKTest()
    }

    func testParameters() {
        engine.output = AKFader(input, gain: 2.0)
        AKTest()
    }

    func testParameters2() {
        engine.output = AKFader(input, gain: 0.5)
        AKTest()
    }
}
