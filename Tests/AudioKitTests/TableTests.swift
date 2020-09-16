// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKTableTests: XCTestCase {

    func testReverseSawtooth() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: AKTable(.reverseSawtooth))
        engine.output = input
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testSawtooth() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: AKTable(.sawtooth))
        engine.output = input
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testSine() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: AKTable(.sine))
        engine.output = input
        // This is just the usual tested sine wave
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testTriangle() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: AKTable(.triangle))
        engine.output = input
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
