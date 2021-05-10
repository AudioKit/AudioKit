// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class DynaRangeCompressorTests: XCTestCase {

    func testAttackTime() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        engine.output = DynaRageCompressor(input, ratio: 10, attackDuration: 21)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDefault() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        engine.output = DynaRageCompressor(input)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameters() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        engine.output = DynaRageCompressor(input,
                                           ratio: 10,
                                           threshold: -1,
                                           attackDuration: 21,
                                           releaseDuration: 22)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testRage() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        engine.output = DynaRageCompressor(input, ratio: 10, rage: 10)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testRatio() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        engine.output = DynaRageCompressor(input, ratio: 10)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testReleaseTime() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        engine.output = DynaRageCompressor(input, ratio: 10, releaseDuration: 22)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testThreshold() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        engine.output = DynaRageCompressor(input, ratio: 10, threshold: -1)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
