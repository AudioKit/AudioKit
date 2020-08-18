// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKPWMOscillatorTests: AKTestCase {

    var oscillator = AKPWMOscillator()

    override func setUp() {
        oscillator.rampDuration = 0.0
        afterStart = { self.oscillator.start() }
    }

    func testDefault() {
        output = oscillator
        AKTestMD5("32911323b68d88bd7d47ed97c1e953b4")
    }

    func testParameters() {
        oscillator = AKPWMOscillator(frequency: 1_234,
                                     amplitude: 0.5,
                                     pulseWidth: 0.75,
                                     detuningOffset: 1.234,
                                     detuningMultiplier: 1.1)
        output = oscillator
        AKTestMD5("84dbd535733cad9824b2ffe4da298274")
    }

    func testFrequency() {
        oscillator = AKPWMOscillator(frequency: 1_234)
        output = oscillator
        AKTestMD5("f6a4dac2c8ce13e709c5bfe77c7d4eaf")
    }

    func testAmplitude() {
        oscillator = AKPWMOscillator(frequency: 1_234, amplitude: 0.5)
        output = oscillator
        AKTestMD5("0ba0ff847a04a46f68ddcd0f5fc65356")
    }

    func testPulseWidth() {
        oscillator = AKPWMOscillator(frequency: 1_234, pulseWidth: 0.75)
        output = oscillator
        AKTestMD5("3e936c8b0afb3cd5fc05b8ded180951f")
    }

    func testDetuningOffset() {
        oscillator = AKPWMOscillator(frequency: 1_234, detuningOffset: 1.234)
        output = oscillator
        AKTestMD5("a23a87d81ac1a3352537b2e91c80ffa8")
    }

    func testDetuningMultiplier() {
        oscillator = AKPWMOscillator(frequency: 1_234, detuningMultiplier: 1.1)
        output = oscillator
        AKTestMD5("07e093a22f65700ad79e128ede1a993d")
    }

    func testParametersSetAfterInit() {
        oscillator = AKPWMOscillator()
        oscillator.rampDuration = 0.0
        oscillator.frequency = 1_234
        oscillator.amplitude = 0.5
        oscillator.pulseWidth = 0.75
        oscillator.detuningOffset = 1.234
        oscillator.detuningMultiplier = 1.11
        output = oscillator
        AKTestMD5("7701ba67e7b7ddf5fb374d06b2601855")
    }}
