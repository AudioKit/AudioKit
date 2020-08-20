// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKFaderTests: AKTestCase {

    func testDefault() {
        output = AKFader(input, gain: 1.0)
        AKTestNoEffect()
    }

    func testBypass() {
        let fader = AKFader(input, gain: 2.0)
        fader.bypass()
        output = fader
        AKTestNoEffect()
    }

    func testMany() {
        let initialFader = AKFader(input, gain: 1.0)
        var nextFader = initialFader
        for _ in 0 ..< 200 {
            let fader = AKFader(nextFader, gain: 1.0)
            nextFader = fader
        }
        output = nextFader
        AKTestNoEffect()
    }

    func testFlipStereo() {
        let pan = AKPanner(input, pan: 1.0)
        let fader = AKFader(pan, gain: 1.0)
        fader.flipStereo = true
        output = fader
        AKTest()
    }

    func testFlipStereoTwice() {
        let pan = AKPanner(input, pan: 1.0)
        let fader = AKFader(pan, gain: 1.0)
        fader.flipStereo = true
        let fader2 = AKFader(fader, gain: 1.0)
        fader2.flipStereo = true
        output = fader2
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
        output = fader3
        AKTest()
    }

    func testMixToMono() {
        let pan = AKPanner(input, pan: 1.0)
        let fader = AKFader(pan, gain: 1.0)
        fader.mixToMono = true
        output = fader
        AKTest()
    }

    func testParameters() {
        output = AKFader(input, gain: 2.0)
        AKTest()
    }

    func testParameters2() {
        output = AKFader(input, gain: 0.5)
        AKTest()
    }
}
