// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKFaderTests: XCTestCase {

    func testDefault() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKFader(input, gain: 1.0)
        input.play()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testBypass() {
        let engine = AKEngine()
        let input = AKOscillator()
        let fader = AKFader(input, gain: 2.0)
        fader.bypass()
        engine.output = fader
        input.play()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testMany() {
        let engine = AKEngine()
        let input = AKOscillator()
        let initialFader = AKFader(input, gain: 1.0)
        var nextFader = initialFader
        for _ in 0 ..< 200 {
            let fader = AKFader(nextFader, gain: 1.0)
            nextFader = fader
        }
        engine.output = nextFader
        input.play()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testFlipStereo() {
        let engine = AKEngine()
        let input = AKOscillator()
        let pan = AKPanner(input, pan: 1.0)
        let fader = AKFader(pan, gain: 1.0)
        fader.flipStereo = true
        engine.output = fader
        input.play()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testFlipStereoTwice() {
        let engine = AKEngine()
        let input = AKOscillator()
        let pan = AKPanner(input, pan: 1.0)
        let fader = AKFader(pan, gain: 1.0)
        fader.flipStereo = true
        let fader2 = AKFader(fader, gain: 1.0)
        fader2.flipStereo = true
        engine.output = fader2
        input.play()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testFlipStereoThrice() {
        let engine = AKEngine()
        let input = AKOscillator()
        let pan = AKPanner(input, pan: 1.0)
        let fader = AKFader(pan, gain: 1.0)
        fader.flipStereo = true
        let fader2 = AKFader(fader, gain: 1.0)
        fader2.flipStereo = true
        let fader3 = AKFader(fader2, gain: 1.0)
        fader3.flipStereo = true
        engine.output = fader3
        input.play()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testMixToMono() {
        let engine = AKEngine()
        let input = AKOscillator()
        let pan = AKPanner(input, pan: 1.0)
        let fader = AKFader(pan, gain: 1.0)
        fader.mixToMono = true
        engine.output = fader
        input.play()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameters() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKFader(input, gain: 2.0)
        input.play()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameters2() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKFader(input, gain: 0.5)
        input.play()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
}
