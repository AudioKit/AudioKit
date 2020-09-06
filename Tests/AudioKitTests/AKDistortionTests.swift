// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKDistortionTests: XCTestCase {

    func testCubicTerm() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKDistortion(input, cubicTerm: 65)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDecay() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKDistortion(input, decay: 2)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDecimation() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKDistortion(input, decimation: 61)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDecimationMix() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKDistortion(input, decimationMix: 62)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDefault() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKDistortion(input)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDelay() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKDistortion(input, delay: 0.2)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDelayMix() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKDistortion(input, delayMix: 60)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testFinalMix() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKDistortion(input, finalMix: 0.69)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testLinearTerm() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKDistortion(input, linearTerm: 63)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameters() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKDistortion(input,
                              delay: 0.2,
                              decay: 2,
                              delayMix: 60,
                              decimation: 61,
                              rounding: 50,
                              decimationMix: 62,
                              linearTerm: 63,
                              squaredTerm: 64,
                              cubicTerm: 65,
                              polynomialMix: 66,
                              ringModFreq1: 200,
                              ringModFreq2: 300,
                              ringModBalance: 67,
                              ringModMix: 68,
                              softClipGain: 0,
                              finalMix: 69)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testPolynomialMix() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKDistortion(input, polynomialMix: 66)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testRingModBalance() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKDistortion(input, ringModBalance: 67, ringModMix: 68)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testRingModFreq1() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKDistortion(input, ringModFreq1: 200, ringModMix: 68)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testRingModFreq2() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKDistortion(input, ringModFreq2: 300, ringModMix: 68)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testRingModMix() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKDistortion(input, ringModMix: 68)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testRounding() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKDistortion(input, rounding: 50)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testSquaredTerm() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKDistortion(input, squaredTerm: 64)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testSoftClipGain() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKDistortion(input, softClipGain: 0)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
