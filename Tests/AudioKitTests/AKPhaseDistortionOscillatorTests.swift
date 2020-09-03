// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest
import CAudioKit

class AKPhaseDistortionOscillatorTests: AKTestCase {

    var oscillator = AKPhaseDistortionOscillator()

    override func setUp() {
        oscillator.rampDuration = 0.0
        afterStart = { self.oscillator.start() }
        AKDebugDSPSetActive(true)
    }

    func testDefault() {
        engine.output = oscillator
        AKTest()
    }

    func testParameters() {
        oscillator = AKPhaseDistortionOscillator(waveform: AKTable(.square),
                                                 frequency: 1_234,
                                                 amplitude: 0.5,
                                                 phaseDistortion: 1.234,
                                                 detuningOffset: 1.234,
                                                 detuningMultiplier: 1.1)
        XCTAssertEqual(oscillator.frequency, 1_234)
        XCTAssertEqual(oscillator.amplitude, 0.5)
        XCTAssertEqual(oscillator.phaseDistortion, 1.234)
        XCTAssertEqual(oscillator.detuningOffset, 1.234)
        XCTAssertEqual(oscillator.detuningMultiplier, 1.1)
        engine.output = oscillator
        AKTest()
    }

    func testFrequency() {
        oscillator = AKPhaseDistortionOscillator(waveform: AKTable(.square), frequency: 1_234)
        engine.output = oscillator
        AKTest()
    }

    func testAmplitude() {
        oscillator = AKPhaseDistortionOscillator(waveform: AKTable(.square), amplitude: 0.5)
        engine.output = oscillator
        AKTest()
    }

    func testPhaseDistortion() {
        oscillator = AKPhaseDistortionOscillator(waveform: AKTable(.square), phaseDistortion: 1.234)
        engine.output = oscillator
        AKTest()
    }

    func testDetuningOffset() {
        oscillator = AKPhaseDistortionOscillator(waveform: AKTable(.square), detuningOffset: 1.234)
        engine.output = oscillator
        AKTest()
    }

    func testDetuningMultiplier() {
        oscillator = AKPhaseDistortionOscillator(waveform: AKTable(.square), detuningMultiplier: 1.1)
        engine.output = oscillator
        AKTest()
    }

    func testParametersSetAfterInit() {
        oscillator = AKPhaseDistortionOscillator(waveform: AKTable(.square))
        oscillator.rampDuration = 0.0
        oscillator.frequency = 1_234
        oscillator.amplitude = 0.5
        oscillator.phaseDistortion = 1.234
        oscillator.detuningOffset = 1.234
        oscillator.detuningMultiplier = 1.1
        engine.output = oscillator
        AKTest()
    }
}
