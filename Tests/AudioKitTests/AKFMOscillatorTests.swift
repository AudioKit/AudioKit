// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKFMOscillatorTests: XCTestCase {

    func testDefault() {
        let engine = AKEngine()
        let oscillator = AKFMOscillator()
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParametersSetAfterInit() {
        let engine = AKEngine()
        let oscillator = AKFMOscillator(waveform: AKTable(.square))
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
        let engine = AKEngine()
        let oscillator = AKFMOscillator(waveform: AKTable(.square),
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

    func testPresetBuzzer() {
        let engine = AKEngine()
        let oscillator = AKFMOscillator()
        oscillator.presetBuzzer()
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testPresetFogHorn() {
        let engine = AKEngine()
        let oscillator = AKFMOscillator()
        oscillator.presetFogHorn()
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testPresetSpiral() {
        let engine = AKEngine()
        let oscillator = AKFMOscillator()
        oscillator.presetSpiral()
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testPresetStunRay() {
        let engine = AKEngine()
        let oscillator = AKFMOscillator()
        oscillator.presetStunRay()
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testPresetWobble() {
        let engine = AKEngine()
        let oscillator = AKFMOscillator()
        oscillator.presetWobble()
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testSquareWave() {
        let engine = AKEngine()
        let oscillator = AKFMOscillator(waveform: AKTable(.square, count: 4_096))
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
