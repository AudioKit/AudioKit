// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class TableTests: XCTestCase {

    func testReverseSawtooth() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.reverseSawtooth))
        engine.output = input
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testSawtooth() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.sawtooth))
        engine.output = input
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    /* Can't test due to sine differences on M1 chip
    func testSine() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.sine))
        engine.output = input
        // This is just the usual tested sine wave
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
 */

    func testTriangle() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        engine.output = input
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    /* Can't test due to sine differences on M1 chip
    func testHarmonicWithPartialAmplitudes() {
        let engine = AudioEngine()
        let partialAmplitudes: [Float] = [0.8, 0.2, 0.3, 0.06, 0.12, 0.0015]
        let input = Oscillator(waveform: Table(.harmonic(partialAmplitudes)))
        engine.output = input
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
 */
}
