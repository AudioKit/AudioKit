// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest
import CAudioKit

class PhaseDistortionOscillatorTests: XCTestCase {

    /* Can't test default because it uses a sine which is different on M1 chip
    func testDefault() {
        let engine = AudioEngine()
        let oscillator = PhaseDistortionOscillator()
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
 */

    func testParameters() {
        let engine = AudioEngine()
        let oscillator = PhaseDistortionOscillator(waveform: Table(.square),
                                                     frequency: 1_234,
                                                     amplitude: 0.5,
                                                     phaseDistortion: 0.234,
                                                     detuningOffset: 1.234,
                                                     detuningMultiplier: 1.1)
        XCTAssertEqual(oscillator.frequency, 1_234)
        XCTAssertEqual(oscillator.amplitude, 0.5)
        XCTAssertEqual(oscillator.phaseDistortion, 0.234)
        XCTAssertEqual(oscillator.detuningOffset, 1.234)
        XCTAssertEqual(oscillator.detuningMultiplier, 1.1)
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testFrequency() {
        let engine = AudioEngine()
        let oscillator = PhaseDistortionOscillator(waveform: Table(.square), frequency: 1_234)
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testAmplitude() {
        let engine = AudioEngine()
        let oscillator = PhaseDistortionOscillator(waveform: Table(.square), amplitude: 0.5)
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testPhaseDistortion() {
        let engine = AudioEngine()
        let oscillator = PhaseDistortionOscillator(waveform: Table(.square), phaseDistortion: 1.234)
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDetuningOffset() {
        let engine = AudioEngine()
        let oscillator = PhaseDistortionOscillator(waveform: Table(.square), detuningOffset: 1.234)
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDetuningMultiplier() {
        let engine = AudioEngine()
        let oscillator = PhaseDistortionOscillator(waveform: Table(.square), detuningMultiplier: 1.1)
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParametersSetAfterInit() {
        let engine = AudioEngine()
        let oscillator = PhaseDistortionOscillator(waveform: Table(.square))
        oscillator.frequency = 1_234
        oscillator.amplitude = 0.5
        oscillator.phaseDistortion = 1.234
        oscillator.detuningOffset = 1.234
        oscillator.detuningMultiplier = 1.1
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
}
