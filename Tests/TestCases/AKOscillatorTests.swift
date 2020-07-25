// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKOscillatorTests: AKTestCase {

    func testAmpitude() {
        input = AKOscillator(waveform: AKTable(.square), amplitude: 0.5)
        output = input
        AKTestMD5("24c58d48adb46e273d63088f6ca30208")
        XCTAssertTrue(AKDebugDSPCheck(AKOscillatorDebugPhase, "e23e315b977c7616b02f3b6534115212"))
    }

    func testDefault() {
        output = input
        AKTestNoEffect()
    }

    func testDetuningMultiplier() {
        input = AKOscillator(waveform: AKTable(.square), detuningMultiplier: 0.9)
        output = input
        AKTestMD5("591d314b30df8d6af0b2e9df86528af1")
        XCTAssertTrue(AKDebugDSPCheck(AKOscillatorDebugPhase, "607f6c8ff1a6ffd0dcd52152ee8cdaae"))
    }

    func testDetuningOffset() {
        input = AKOscillator(waveform: AKTable(.square), detuningOffset: 11)
        output = input
        AKTestMD5("c0d0d9e1cb39611efaf0b7b8b8d7c137")
        XCTAssertTrue(AKDebugDSPCheck(AKOscillatorDebugPhase, "6a92817df787e4465991fe249b2245d4"))
    }

    func testFrequency() {
        input = AKOscillator(waveform: AKTable(.square), frequency: 400)
        output = input
        AKTestMD5("d3998b51af7f54f1c9088973b931e9af")
        XCTAssertTrue(AKDebugDSPCheck(AKOscillatorDebugPhase, "ea430adbf3a856d283cc32e0f9601c9f"))
    }

    func testParametersSetAfterInit() {
        input = AKOscillator(waveform: AKTable(.square))
        input.rampDuration = 0.0
        input.frequency = 400
        input.amplitude = 0.5
        output = input
        AKTestMD5("615e742bc1412c15237a453c5b49d5e0")
        XCTAssertTrue(AKDebugDSPCheck(AKOscillatorDebugPhase, "ea430adbf3a856d283cc32e0f9601c9f"))
    }

    func testParameters() {
        input = AKOscillator(waveform: AKTable(.square), frequency: 400, amplitude: 0.5)
        output = input
        AKTestMD5("615e742bc1412c15237a453c5b49d5e0")
        XCTAssertTrue(AKDebugDSPCheck(AKOscillatorDebugPhase, "ea430adbf3a856d283cc32e0f9601c9f"))
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

        AKTestMD5("9965c44f94946252a78cba4c1f8df1e9")
        XCTAssertTrue(AKDebugDSPCheck(AKOscillatorDebugPhase, "9787bab4e82bba7a2ec1dcf34edf8156"))
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

        //auditionTest()

        AKTestMD5("f1f313f396fd5962a36db24e675df274")
        XCTAssertTrue(AKDebugDSPCheck(AKOscillatorDebugPhase, "ea430adbf3a856d283cc32e0f9601c9f"))
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

        AKTestMD5("33320d40f5fa6f469d06f877aae338a8")
        XCTAssertTrue(AKDebugDSPCheck(AKOscillatorDebugPhase, "9787bab4e82bba7a2ec1dcf34edf8156"))
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

        AKTestMD5("9965c44f94946252a78cba4c1f8df1e9")
        XCTAssertTrue(AKDebugDSPCheck(AKOscillatorDebugPhase, "9787bab4e82bba7a2ec1dcf34edf8156"))
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

        AKTestMD5("f1f313f396fd5962a36db24e675df274")
        XCTAssertTrue(AKDebugDSPCheck(AKOscillatorDebugPhase, "ea430adbf3a856d283cc32e0f9601c9f"))
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

        AKTestMD5("33320d40f5fa6f469d06f877aae338a8")
        XCTAssertTrue(AKDebugDSPCheck(AKOscillatorDebugPhase, "9787bab4e82bba7a2ec1dcf34edf8156"))
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

        AKTestMD5("1ce448c3c5c3d1020990917931b0116b")

    }

}
