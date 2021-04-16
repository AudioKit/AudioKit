// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class FaderTests: XCTestCase {

    func testDefault() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        engine.output = Fader(input, gain: 1.0)
        input.play()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testGain() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        engine.output = Fader(input, gain: 0.5)
        input.play()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testBypass() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        let fader = Fader(input, gain: 2.0)
        fader.bypass()
        engine.output = fader
        input.play()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testMany() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        let initialFader = Fader(input, gain: 1.0)
        var nextFader = initialFader
        for _ in 0 ..< 200 {
            let fader = Fader(nextFader, gain: 1.0)
            nextFader = fader
        }
        engine.output = nextFader
        input.play()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testFlipStereo() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        let pan = Panner(input, pan: 1.0)
        let fader = Fader(pan, gain: 1.0)
        fader.flipStereo = true
        engine.output = fader
        input.play()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testFlipStereoTwice() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        let pan = Panner(input, pan: 1.0)
        let fader = Fader(pan, gain: 1.0)
        fader.flipStereo = true
        let fader2 = Fader(fader, gain: 1.0)
        fader2.flipStereo = true
        engine.output = fader2
        input.play()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testFlipStereoThrice() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        let pan = Panner(input, pan: 1.0)
        let fader = Fader(pan, gain: 1.0)
        fader.flipStereo = true
        let fader2 = Fader(fader, gain: 1.0)
        fader2.flipStereo = true
        let fader3 = Fader(fader2, gain: 1.0)
        fader3.flipStereo = true
        engine.output = fader3
        input.play()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testMixToMono() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        let pan = Panner(input, pan: 1.0)
        let fader = Fader(pan, gain: 1.0)
        fader.mixToMono = true
        engine.output = fader
        input.play()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameters() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        engine.output = Fader(input, gain: 2.0)
        input.play()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameters2() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        engine.output = Fader(input, gain: 0.5)
        input.play()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
}
