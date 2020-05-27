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
        output = oscillator
        AKTestMD5("b3168bffcc63e44c6850fbf7c17ad98d")
    }

    func testParametersSetAfterInit() {
        oscillator = AKMorphingOscillator(waveformArray: waveforms)
        oscillator.rampDuration = 0
        oscillator.frequency.value = 1_234
        oscillator.amplitude.value = 0.5
        oscillator.index.value = 1.234
        oscillator.detuningOffset.value = 11
        oscillator.detuningMultiplier.value = 1.1
        output = oscillator
        AKTestMD5("382e738d40fdda8c38e4b9ad1fbde591")
    }

    func testParametersSetOnInit() {
        oscillator = AKMorphingOscillator(waveformArray: waveforms,
                                          frequency: 1_234,
                                          amplitude: 0.5,
                                          index: 1.234,
                                          detuningOffset: 11,
                                          detuningMultiplier: 1.1)
        output = oscillator

        AKTestMD5("382e738d40fdda8c38e4b9ad1fbde591")
    }
}
