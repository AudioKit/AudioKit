// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest
import CAudioKit
import AVFoundation

class OscillatorAutomationTests: XCTestCase {

    func testNewAutomationFrequency() {
        let engine = AudioEngine()
        let oscillator = Oscillator(waveform: Table(.square), frequency: 400, amplitude: 0.5)
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        let event = AutomationEvent(targetValue: 880, startTime: 0, rampDuration: 1.0)
        oscillator.$frequency.automate(events: [event])
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testNewAutomationAmplitude() {
        let engine = AudioEngine()
        let oscillator = Oscillator(waveform: Table(.square), frequency: 400, amplitude: 0.0)

        engine.output = oscillator

        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        let event = AutomationEvent(targetValue: 1.0, startTime: 0, rampDuration: 1.0)
        oscillator.$amplitude.automate(events: [event])
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testNewAutomationMultiple() {
        let engine = AudioEngine()
        let oscillator = Oscillator(waveform: Table(.square), frequency: 400, amplitude: 0.0)

        engine.output = oscillator

        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        
        let frequencyEvent = AutomationEvent(targetValue: 880, startTime: 0, rampDuration: 1.0)
        oscillator.$frequency.automate(events: [frequencyEvent])
        
        let amplitudeEvent = AutomationEvent(targetValue: 1.0, startTime: 0, rampDuration: 1.0)
        oscillator.$amplitude.automate(events: [amplitudeEvent])
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testNewAutomationDelayed() {
        let engine = AudioEngine()
        let oscillator = Oscillator(waveform: Table(.triangle), frequency: 400, amplitude: 0.5)
        engine.output = oscillator

        oscillator.start()
        let audio = engine.startTest(totalDuration: 2.0)

        // Delay a second.
        let startTime = AVAudioTime(sampleTime: 44100, atRate: 41000)

        let event = AutomationEvent(targetValue: 880, startTime: 0, rampDuration: 1.0)
        oscillator.$frequency.automate(events: [event], startTime: startTime)

        audio.append(engine.render(duration: 2.0))
        testMD5(audio)
    }
}
