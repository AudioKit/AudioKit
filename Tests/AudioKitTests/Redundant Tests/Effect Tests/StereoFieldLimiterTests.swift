// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class StereoFieldLimiterTests: XCTestCase {

    func testDefault() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        let pannedInput = Panner(input, pan: -1)
        engine.output = StereoFieldLimiter(pannedInput)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testHalf() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        let pannedInput = Panner(input, pan: -1)
        engine.output = StereoFieldLimiter(pannedInput, amount: 0.5)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testNone() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        let pannedInput = Panner(input, pan: -1)
        engine.output = StereoFieldLimiter(pannedInput, amount: 0)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
}
