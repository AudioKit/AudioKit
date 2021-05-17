// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest
import CAudioKit
import AVFoundation

class DynamicOscillatorTests: XCTestCase {

    func testNewAutomationFrequency() {
        let engine = AudioEngine()
        let oscillator = DynamicOscillator(waveform: Table(.square), frequency: 400, amplitude: 0.5)
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        oscillator.$frequency.automate(events: [AutomationEvent(targetValue: 880,
                                                             startTime: 0,
                                                             rampDuration: 1.0)])
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testNewAutomationAmplitude() {
        let engine = AudioEngine()
        let oscillator = DynamicOscillator(waveform: Table(.square), frequency: 400, amplitude: 0.0)

        engine.output = oscillator

        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        oscillator.$amplitude.automate(events: [AutomationEvent(targetValue: 1.0,
                                                             startTime: 0,
                                                             rampDuration: 1.0)])
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testNewAutomationMultiple() {
        let engine = AudioEngine()
        let oscillator = DynamicOscillator(waveform: Table(.square), frequency: 400, amplitude: 0.0)

        engine.output = oscillator

        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        oscillator.$frequency.automate(events: [AutomationEvent(targetValue: 880,
                                                             startTime: 0,
                                                             rampDuration: 1.0)])
        oscillator.$amplitude.automate(events: [AutomationEvent(targetValue: 1.0,
                                                             startTime: 0,
                                                             rampDuration: 1.0)])
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testNewAutomationDelayed() {
        let engine = AudioEngine()
        let oscillator = DynamicOscillator(waveform: Table(.sawtooth), frequency: 400, amplitude: 0.5)
        engine.output = oscillator

        oscillator.start()
        let audio = engine.startTest(totalDuration: 2.0)

        // Delay a second.
        let startTime = AVAudioTime(sampleTime: 44100, atRate: 41000)

        oscillator.$frequency.automate(events: [AutomationEvent(targetValue: 880,
                                                             startTime: 0,
                                                             rampDuration: 1.0)],
                                  startTime: startTime)

        audio.append(engine.render(duration: 2.0))
        testMD5(audio)
    }

    func testSetWavetable() {
        let engine = AudioEngine()
        let oscillator = DynamicOscillator(frequency: 400)
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 0.5))
        oscillator.setWaveTable(waveform: Table(.square))
        audio.append(engine.render(duration: 0.5))
        testMD5(audio)
    }

    func testGetWavetableValues() {
        let engine = AudioEngine()
        let oscillator = DynamicOscillator(waveform: Table(.square), frequency: 400)
        let floats = oscillator.getWavetableValues()
        XCTAssertEqual(floats, Table(.square).content)
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testWavetableUpdateHandler() {
        let engine = AudioEngine()
        var floats: [Float] = []
        let oscillator = DynamicOscillator(waveform: Table(.square), frequency: 400)
        oscillator.wavetableUpdateHandler = { newFloats in
            floats = newFloats
        }
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        oscillator.setWaveTable(waveform: Table(.square))
        audio.append(engine.render(duration: 1.0))
        XCTAssertEqual(floats, Table(.square).content)
        testMD5(audio)
    }
}
