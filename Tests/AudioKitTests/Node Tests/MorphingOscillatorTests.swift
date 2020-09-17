// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class MorphingOscillatorTests: XCTestCase {

    let waveforms = [Table(.sine), Table(.triangle), Table(.sawtooth), Table(.square)]

    func testDefault() {
        let engine = AudioEngine()
        let oscillator = MorphingOscillator()
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParametersSetAfterInit() {
        let engine = AudioEngine()
        let oscillator = MorphingOscillator(waveformArray: waveforms)
        oscillator.frequency = 1_234
        oscillator.amplitude = 0.5
        oscillator.index = 1.234
        oscillator.detuningOffset = 11
        oscillator.detuningMultiplier = 1.1
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParametersSetOnInit() {
        let engine = AudioEngine()
        let oscillator = MorphingOscillator(waveformArray: waveforms,
                                              frequency: 1_234,
                                              amplitude: 0.5,
                                              index: 1.234,
                                              detuningOffset: 11,
                                              detuningMultiplier: 1.1)
        engine.output = oscillator

        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
}
