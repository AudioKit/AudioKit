// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest
import CAudioKit
import AVFoundation

class AKOscillatorTests: AKTestCase {
    func testAmpitude() {
        input = AKOscillator(waveform: AKTable(.square), amplitude: 0.5)
        output = input
        XCTAssertEqual(input.amplitude, 0.5)
        AKTest()
    }

    func testDefault() {
        output = input
        AKTest()
    }

    func testDetuningMultiplier() {
        input = AKOscillator(waveform: AKTable(.square), detuningMultiplier: 0.9)
        output = input
        XCTAssertEqual(input.detuningMultiplier, 0.9)
        AKTest()
    }

    func testDetuningOffset() {
        input = AKOscillator(waveform: AKTable(.square), detuningOffset: 11)
        output = input
        XCTAssertEqual(input.detuningOffset, 11)
        AKTest()
    }

    func testFrequency() {
        input = AKOscillator(waveform: AKTable(.square), frequency: 400)
        output = input
        XCTAssertEqual(input.frequency, 400)
        AKTest()
    }

    func testParametersSetAfterInit() {
        input = AKOscillator(waveform: AKTable(.square))
        input.rampDuration = 0.0
        input.frequency = 400
        input.amplitude = 0.5
        XCTAssertEqual(input.rampDuration, 0.0)
        XCTAssertEqual(input.frequency, 400)
        XCTAssertEqual(input.amplitude, 0.5)
        output = input
        AKTest()
    }

    func testParameters() {
        input = AKOscillator(waveform: AKTable(.square), frequency: 400, amplitude: 0.5)
        output = input
        AKTest()
    }

    func testAutomationFrequency() {
        input = AKOscillator(waveform: AKTable(.square), frequency: 400, amplitude: 0.5)
        input.parameterAutomation?.add(point: AKParameterAutomationPoint(targetValue: 880,
                                                                         startTime: 0,
                                                                         rampDuration: duration),
                                       to: input.$frequency)
        output = input

        afterStart = {
            self.input.parameterAutomation?.startPlayback()
        }

        // auditionTest()

        AKTest()
    }

    func testAutomationAmplitude() {
        input = AKOscillator(waveform: AKTable(.square), frequency: 400, amplitude: 0.0)
        input.parameterAutomation?.add(point: AKParameterAutomationPoint(targetValue: 1.0,
                                                                         startTime: 0,
                                                                         rampDuration: duration),
                                       to: input.$amplitude)
        output = input

        afterStart = {
            self.input.parameterAutomation?.startPlayback()
        }

        // auditionTest()

        AKTest()
    }

    func testAutomationMultiple() {
        input = AKOscillator(waveform: AKTable(.square), frequency: 400, amplitude: 0.0)
        input.parameterAutomation?.add(point: AKParameterAutomationPoint(targetValue: 880,
                                                                         startTime: 0,
                                                                         rampDuration: duration),
                                       to: input.$frequency)
        input.parameterAutomation?.add(point: AKParameterAutomationPoint(targetValue: 1.0,
                                                                         startTime: 0,
                                                                         rampDuration: duration),
                                       to: input.$amplitude)
        output = input

        afterStart = {
            self.input.parameterAutomation?.startPlayback()
        }

        // auditionTest()

        AKTest()
    }

    func testNewAutomationFrequency() {
        input = AKOscillator(waveform: AKTable(.square), frequency: 400, amplitude: 0.5)
        output = input

        afterStart = {
            self.input.$frequency.automate(events: [AKAutomationEvent(targetValue: 880,
                                                                      startTime: 0,
                                                                      rampDuration: self.duration)])
        }

        // auditionTest()

        AKTest()
    }

    func testNewAutomationAmplitude() {
        input = AKOscillator(waveform: AKTable(.square), frequency: 400, amplitude: 0.0)

        output = input

        afterStart = {
            self.input.$amplitude.automate(events: [AKAutomationEvent(targetValue: 1.0,
                                                                      startTime: 0,
                                                                      rampDuration: self.duration)])
        }

        // auditionTest()

        AKTest()
    }

    func testNewAutomationMultiple() {
        input = AKOscillator(waveform: AKTable(.square), frequency: 400, amplitude: 0.0)

        output = input

        afterStart = {
            self.input.$frequency.automate(events: [AKAutomationEvent(targetValue: 880,
                                                                      startTime: 0,
                                                                      rampDuration: self.duration)])
            self.input.$amplitude.automate(events: [AKAutomationEvent(targetValue: 1.0,
                                                                      startTime: 0,
                                                                      rampDuration: self.duration)])
        }

        // auditionTest()

        AKTest()
    }

    func testNewAutomationDelayed() {
        // Play for two seconds.
        duration = 2.0

        input = AKOscillator(waveform: AKTable(.sine), frequency: 400, amplitude: 0.5)
        output = input

        afterStart = {
            // Delay a second.
            let startTime = AVAudioTime(sampleTime: 44100, atRate: 41000)

            self.input.$frequency.automate(events: [AKAutomationEvent(targetValue: 880,
                                                                      startTime: 0,
                                                                      rampDuration: 1.0)],
                                           startTime: startTime)
        }

        // auditionTest()

        AKTest()
    }
}
