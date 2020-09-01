// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKPWMOscillatorTests: AKTestCase {

    var oscillator = AKPWMOscillator()

    override func setUp() {
        oscillator.rampDuration = 0.0
        afterStart = { self.oscillator.start() }
    }

    func testDefault() {
        engine.output = oscillator
        AKTest()
    }

    func testParameters() {
        oscillator = AKPWMOscillator(frequency: 1_234,
                                     amplitude: 0.5,
                                     pulseWidth: 0.75,
                                     detuningOffset: 1.234,
                                     detuningMultiplier: 1.1)
        engine.output = oscillator
        AKTest()
    }

    func testFrequency() {
        oscillator = AKPWMOscillator(frequency: 1_234)
        engine.output = oscillator
        AKTest()
    }

    func testAmplitude() {
        oscillator = AKPWMOscillator(frequency: 1_234, amplitude: 0.5)
        engine.output = oscillator
        AKTest()
    }

    func testPulseWidth() {
        oscillator = AKPWMOscillator(frequency: 1_234, pulseWidth: 0.75)
        engine.output = oscillator
        AKTest()
    }

    func testDetuningOffset() {
        oscillator = AKPWMOscillator(frequency: 1_234, detuningOffset: 1.234)
        engine.output = oscillator
        AKTest()
    }

    func testDetuningMultiplier() {
        oscillator = AKPWMOscillator(frequency: 1_234, detuningMultiplier: 1.1)
        engine.output = oscillator
        AKTest()
    }

    func testParametersSetAfterInit() {
        oscillator = AKPWMOscillator()
        oscillator.rampDuration = 0.0
        oscillator.frequency = 1_234
        oscillator.amplitude = 0.5
        oscillator.pulseWidth = 0.75
        oscillator.detuningOffset = 1.234
        oscillator.detuningMultiplier = 1.11
        engine.output = oscillator
        AKTest()
    }}
