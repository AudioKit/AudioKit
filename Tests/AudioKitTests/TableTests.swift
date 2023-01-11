// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

// XXX: don't need to use Engine to test Table
class TableTests: XCTestCase {
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
    func testReverseSawtooth() {
        let engine = Engine()
        let osc = Oscillator(waveform: Table(.reverseSawtooth))
        engine.output = osc
        osc.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
    func testSawtooth() {
        let engine = Engine()
        let input = Oscillator(waveform: Table(.sawtooth))
        engine.output = input
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testSine() {
        let engine = Engine()
        let input = Oscillator(waveform: Table(.sine))
        engine.output = input
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testTriangle() {
        let engine = Engine()
        let input = Oscillator(waveform: Table(.triangle))
        engine.output = input
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testHarmonicWithPartialAmplitudes() {
        let engine = Engine()
        let partialAmplitudes: [Float] = [0.8, 0.2, 0.3, 0.06, 0.12, 0.0015]
        let input = Oscillator(waveform: Table(.harmonic(partialAmplitudes)))
        engine.output = input
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
}
