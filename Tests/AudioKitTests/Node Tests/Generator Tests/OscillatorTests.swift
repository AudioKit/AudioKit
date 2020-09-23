// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest
import CAudioKit
import AVFoundation

class OscillatorTests: XCTestCase {
    func testAmpitude() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.square), amplitude: 0.5)
        engine.output = input
        XCTAssertEqual(input.amplitude, 0.5)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDefault() {
        let engine = AudioEngine()
        let input = Oscillator()
        engine.output = input
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDetuningMultiplier() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.square), detuningMultiplier: 0.9)
        engine.output = input
        XCTAssertEqual(input.detuningMultiplier, 0.9)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDetuningOffset() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.square), detuningOffset: 11)
        engine.output = input
        XCTAssertEqual(input.detuningOffset, 11)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testFrequency() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.square), frequency: 400)
        engine.output = input
        XCTAssertEqual(input.frequency, 400)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParametersSetAfterInit() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.square))
        input.frequency = 400
        input.amplitude = 0.5
        XCTAssertEqual(input.frequency, 400)
        XCTAssertEqual(input.amplitude, 0.5)
        engine.output = input
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameters() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.square), frequency: 400, amplitude: 0.5)
        engine.output = input
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testNewAutomationFrequency() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.square), frequency: 400, amplitude: 0.5)
        engine.output = input
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        input.$frequency.automate(events: [AutomationEvent(targetValue: 880,
                                                             startTime: 0,
                                                             rampDuration: 1.0)])
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testNewAutomationAmplitude() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.square), frequency: 400, amplitude: 0.0)

        engine.output = input

        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        input.$amplitude.automate(events: [AutomationEvent(targetValue: 1.0,
                                                             startTime: 0,
                                                             rampDuration: 1.0)])
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testNewAutomationMultiple() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.square), frequency: 400, amplitude: 0.0)

        engine.output = input

        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        input.$frequency.automate(events: [AutomationEvent(targetValue: 880,
                                                             startTime: 0,
                                                             rampDuration: 1.0)])
        input.$amplitude.automate(events: [AutomationEvent(targetValue: 1.0,
                                                             startTime: 0,
                                                             rampDuration: 1.0)])
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testNewAutomationDelayed() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.sine), frequency: 400, amplitude: 0.5)
        engine.output = input

        input.start()
        let audio = engine.startTest(totalDuration: 2.0)

        // Delay a second.
        let startTime = AVAudioTime(sampleTime: 44100, atRate: 41000)

        input.$frequency.automate(events: [AutomationEvent(targetValue: 880,
                                                             startTime: 0,
                                                             rampDuration: 1.0)],
                                  startTime: startTime)

        audio.append(engine.render(duration: 2.0))
        testMD5(audio)
    }
}
