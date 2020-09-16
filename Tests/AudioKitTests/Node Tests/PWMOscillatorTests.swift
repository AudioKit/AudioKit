// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKPWMOscillatorTests: XCTestCase {

    func testDefault() {
        let engine = AKEngine()
        let oscillator = AKPWMOscillator()
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameters() {
        let engine = AKEngine()
        let oscillator = AKPWMOscillator(frequency: 1_234,
                                         amplitude: 0.5,
                                         pulseWidth: 0.75,
                                         detuningOffset: 1.234,
                                         detuningMultiplier: 1.1)
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testFrequency() {
        let engine = AKEngine()
        let oscillator = AKPWMOscillator(frequency: 1_234)
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testAmplitude() {
        let engine = AKEngine()
        let oscillator = AKPWMOscillator(frequency: 1_234, amplitude: 0.5)
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testPulseWidth() {
        let engine = AKEngine()
        let oscillator = AKPWMOscillator(frequency: 1_234, pulseWidth: 0.75)
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDetuningOffset() {
        let engine = AKEngine()
        let oscillator = AKPWMOscillator(frequency: 1_234, detuningOffset: 1.234)
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDetuningMultiplier() {
        let engine = AKEngine()
        let oscillator = AKPWMOscillator(frequency: 1_234, detuningMultiplier: 1.1)
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParametersSetAfterInit() {
        let engine = AKEngine()
        let oscillator = AKPWMOscillator()
        oscillator.frequency = 1_234
        oscillator.amplitude = 0.5
        oscillator.pulseWidth = 0.75
        oscillator.detuningOffset = 1.234
        oscillator.detuningMultiplier = 1.11
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }}
