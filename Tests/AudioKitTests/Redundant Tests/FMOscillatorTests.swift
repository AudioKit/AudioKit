// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class FMOscillatorTests: XCTestCase {

    /* Can't test default because it uses a sine which is different on M1 chip
    func testDefault() {
        let engine = AudioEngine()
        let oscillator = FMOscillator()
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
    */

    func testParametersSetAfterInit() {
        let engine = AudioEngine()
        let oscillator = FMOscillator(waveform: Table(.square))
        oscillator.baseFrequency = 1_234
        oscillator.carrierMultiplier = 1.234
        oscillator.modulatingMultiplier = 1.234
        oscillator.modulationIndex = 1.234
        oscillator.amplitude = 0.5
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParametersSetOnInit() {
        let engine = AudioEngine()
        let oscillator = FMOscillator(waveform: Table(.square),
                                        baseFrequency: 1_234,
                                        carrierMultiplier: 1.234,
                                        modulatingMultiplier: 1.234,
                                        modulationIndex: 1.234,
                                        amplitude: 0.5)
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
}
