// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKFMOscillatorTests: AKTestCase {

    var oscillator = AKFMOscillator()

    override func setUp() {
        oscillator.rampDuration = 0.0
        afterStart = { self.oscillator.start() }
    }

    func testDefault() {
        engine.output = oscillator
        AKTest()
    }

    func testParametersSetAfterInit() {
        oscillator = AKFMOscillator(waveform: AKTable(.square))
        oscillator.rampDuration = 0.0
        oscillator.baseFrequency = 1_234
        oscillator.carrierMultiplier = 1.234
        oscillator.modulatingMultiplier = 1.234
        oscillator.modulationIndex = 1.234
        oscillator.amplitude = 0.5
        engine.output = oscillator
        AKTest()
    }

    func testParametersSetOnInit() {
        oscillator = AKFMOscillator(waveform: AKTable(.square),
                                    baseFrequency: 1_234,
                                    carrierMultiplier: 1.234,
                                    modulatingMultiplier: 1.234,
                                    modulationIndex: 1.234,
                                    amplitude: 0.5)
        engine.output = oscillator
        AKTest()
    }

    func testPresetBuzzer() {
        oscillator.presetBuzzer()
        engine.output = oscillator
        AKTest()
    }

    func testPresetFogHorn() {
        oscillator.presetFogHorn()
        engine.output = oscillator
        AKTest()
    }

    func testPresetSpiral() {
        oscillator.presetSpiral()
        engine.output = oscillator
        AKTest()
    }

    func testPresetStunRay() {
        oscillator.presetStunRay()
        engine.output = oscillator
        AKTest()
    }

    func testPresetWobble() {
        oscillator.presetWobble()
        engine.output = oscillator
        AKTest()
    }

    func testSquareWave() {
        oscillator = AKFMOscillator(waveform: AKTable(.square, count: 4_096))
        engine.output = oscillator
        AKTest()
    }

}
