// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKMorphingOscillatorTests: AKTestCase {

    let waveforms = [AKTable(.sine), AKTable(.triangle), AKTable(.sawtooth), AKTable(.square)]

    var oscillator = AKMorphingOscillator()

    override func setUp() {
        oscillator.rampDuration = 0.0
        afterStart = { self.oscillator.start() }
    }

    func testDefault() {
        engine.output = oscillator
        AKTest()
    }

    func testParametersSetAfterInit() {
        oscillator = AKMorphingOscillator(waveformArray: waveforms)
        oscillator.rampDuration = 0
        oscillator.frequency = 1_234
        oscillator.amplitude = 0.5
        oscillator.index = 1.234
        oscillator.detuningOffset = 11
        oscillator.detuningMultiplier = 1.1
        engine.output = oscillator
        AKTest()
    }

    func testParametersSetOnInit() {
        oscillator = AKMorphingOscillator(waveformArray: waveforms,
                                          frequency: 1_234,
                                          amplitude: 0.5,
                                          index: 1.234,
                                          detuningOffset: 11,
                                          detuningMultiplier: 1.1)
        engine.output = oscillator

        AKTest()
    }
}
