// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
@testable import AudioKit
import XCTest

class OperationTests: XCTestCase {

    func testAdd() {
        let operation1 = Operation.sineWave()
        let operation2 = Operation.squareWave()
        let sum = operation1 + operation2
        XCTAssertEqual(sum.sporth, #""ak" "0 0" gen_vals 440.0 1.0 sine 0 "ak" tset 440.0 1.0 0.5 blsquare 1 "ak" tset 0 "ak" tget 1 "ak" tget + "#)
    }

    func testBitCrush() {
        let generator = Operation.sineWave(frequency: 1.1, amplitude: 2.2)
        let output = generator.bitCrush(bitDepth: 8, sampleRate: 8000)
        XCTAssertEqual(output.sporth, #""ak" "0" gen_vals 1.1 2.2 sine 0 "ak" tset 0 "ak" tget 8.0 8000.0 bitcrush "#)
    }

    func testBrownianNoise() {
        let operation = Operation.brownianNoise(amplitude: 0.9)
        XCTAssertEqual(operation.sporth, "0.9 brown * ")
    }

    func testClip() {
        let generator = Operation.sineWave(frequency: 1.1, amplitude: 2.2)
        let output = generator.clip(0.7)
        XCTAssertEqual(output.sporth, #""ak" "0" gen_vals 1.1 2.2 sine 0 "ak" tset 0 "ak" tget 0.7 clip "#)
    }

    func testCount() {
        let operation = Operation.periodicTrigger(period: 1.1).count(maximum: 9, looping: true)
        XCTAssertEqual(operation.sporth, #""ak" "0" gen_vals 1.1 dmetro 0 "ak" tset 0 "ak" tget 9.0 0.0 count "#)
    }

    func testDelay() {
        let generator = Operation.sineWave(frequency: 1.1, amplitude: 2.2)
        let output = generator.delay(time: 1.2, feedback: 0.8)
        XCTAssertEqual(output.sporth, #""ak" "0" gen_vals 1.1 2.2 sine 0 "ak" tset 0 "ak" tget 0.8 1.2 delay "#)
    }

    func testDistort() {
        let generator = Operation.sineWave(frequency: 1.1, amplitude: 2.2)
        let output = generator.distort(pregain: 0.6, postgain: 1.5, positiveShapeParameter: 0.7, negativeShapeParameter: 0.8)
        XCTAssertEqual(output.sporth, #""ak" "0" gen_vals 1.1 2.2 sine 0 "ak" tset 0 "ak" tget 0.6 1.5 0.7 0.8 dist "#)
    }

    func testDivide() {
        let operation1 = Operation.sineWave()
        let operation2 = Operation.squareWave()
        let quotient = operation1 / operation2
        XCTAssertEqual(quotient.sporth, #""ak" "0 0" gen_vals 440.0 1.0 sine 0 "ak" tset 440.0 1.0 0.5 blsquare 1 "ak" tset 0 "ak" tget 1 "ak" tget / "#)
    }

    func testExponentialSegment() {
        let operation = Operation.exponentialSegment(trigger: Operation.metronome(), start: 0.7, end: 1.1, duration: 0.3)
        XCTAssertEqual(operation.sporth, #""ak" "0" gen_vals 2.0 metro 0 "ak" tset 0 "ak" tget 0.7 0.3 1.1 expon "#)
    }

    func testFMOscillator() {
        let operation = Operation.fmOscillator(baseFrequency: 220, carrierMultiplier: 1.1, modulatingMultiplier: 1.2, modulationIndex: 1.3, amplitude: 1.4)
        XCTAssertEqual(operation.sporth, "220.0 1.4 1.1 1.2 1.3 fm ")
    }

    func testIncrement() {
        let operation = Operation.periodicTrigger(period: 1.1).increment(on: 1.1, by: 1.2, minimum: 0.1, maximum: 11.1)
        XCTAssertEqual(operation.sporth, #""ak" "0" gen_vals 1.1 dmetro 0 "ak" tset 1.1 1.2 0.1 11.1 0 "ak" tget incr "#)
    }

    func testJitter() {
        let operation = Operation.jitter(amplitude: 1.1, minimumFrequency: 1.2, maximumFrequency: 1.3)
        XCTAssertEqual(operation.sporth, "1.1 1.2 1.3 jitter ")
    }

    func testLineSegment() {
        let operation = Operation.lineSegment(trigger: Operation.metronome(), start: 0.7, end: 1.1, duration: 0.3)
        XCTAssertEqual(operation.sporth, #""ak" "0" gen_vals 2.0 metro 0 "ak" tset 0 "ak" tget 0.7 0.3 1.1 line "#)
    }

    func testMax() {
        let operation1 = Operation.sineWave()
        let operation2 = Operation.squareWave()
        let maximum = max(operation1, operation2)
        XCTAssertEqual(maximum.sporth, #""ak" "0 0" gen_vals 440.0 1.0 sine 0 "ak" tset 440.0 1.0 0.5 blsquare 1 "ak" tset 0 "ak" tget 1 "ak" tget max "#)
    }

    func testMin() {
        let operation1 = Operation.sineWave()
        let operation2 = Operation.squareWave()
        let minimum = min(operation1, operation2)
        XCTAssertEqual(minimum.sporth, #""ak" "0 0" gen_vals 440.0 1.0 sine 0 "ak" tset 440.0 1.0 0.5 blsquare 1 "ak" tset 0 "ak" tget 1 "ak" tget min "#)
    }

    func testMix() {
        let operation1 = Operation.sineWave()
        let operation2 = Operation.squareWave()
        let mix = mixer(operation1, operation2, balance: 0.7)
        XCTAssertEqual(mix.sporth, #""ak" "0 0" gen_vals 440.0 1.0 sine 0 "ak" tset 440.0 1.0 0.5 blsquare 1 "ak" tset 0 "ak" tget 1 "ak" tget 0.7 1 swap - cf "#)
    }

    func testMorphingOscillator() {
        let operation = Operation.morphingOscillator(frequency: 220, amplitude: 0.8, index: 2)
        XCTAssertEqual(operation.sporth, #""sine" 4096 gen_sine  "square" 4096 "0 1 2047 1 2048 -1 4095 -1" gen_line  "sawtooth" 4096 "0 -1 4095 1" gen_line  "revsaw" 4096 "0 1 4095 -1" gen_line  220.0 0.8 2.0 3 / 0 "sine" "square" "sawtooth" "revsaw" oscmorph4 "#)
    }

    func testMultiply() {
        let operation1 = Operation.sineWave()
        let operation2 = Operation.squareWave()
        let multiple = operation1 * operation2
        XCTAssertEqual(multiple.sporth, #""ak" "0 0" gen_vals 440.0 1.0 sine 0 "ak" tset 440.0 1.0 0.5 blsquare 1 "ak" tset 0 "ak" tget 1 "ak" tget * "#)
    }

    func testPan() {
        let generator = Operation.sineWave(frequency: 1.1, amplitude: 2.2)
        let output = generator.pan(0.7)
        XCTAssertEqual(output.sporth, #""ak" "0" gen_vals 1.1 2.2 sine 0 "ak" tset 0 "ak" tget 0.7 pan "#)
    }

    func testPhasor() {
        let operation = Operation.phasor(frequency: 1.1, phase: 0.1)
        XCTAssertEqual(operation.sporth, "1.1 0.1 phasor ")
    }

    func testPinkNoise() {
        let operation = Operation.pinkNoise(amplitude: 0.9)
        XCTAssertEqual(operation.sporth, "0.9 pinknoise ")
    }

    func testRandomNumberPulse() {
        let operation = Operation.randomNumberPulse(minimum: 1.1, maximum: 1.2, updateFrequency: 1.3)
        XCTAssertEqual(operation.sporth, "1.1 1.2 1.3 randh ")
    }

    func testRandomVertexPulse() {
        let operation = Operation.randomVertexPulse(minimum: 1.1, maximum: 1.2, updateFrequency: 1.3)
        XCTAssertEqual(operation.sporth, "1.1 1.2 1.3 randi ")
    }

    func testReverberateWithChowning() {
        let generator = Operation.sineWave(frequency: 1.1, amplitude: 2.2)
        let output = generator.reverberateWithChowning()
        XCTAssertEqual(output.sporth, #""ak" "0" gen_vals 1.1 2.2 sine 0 "ak" tset 0 "ak" tget jcrev "#)
    }

    func testReverberateWithCombFilter() {
        let generator = Operation.sineWave(frequency: 1.1, amplitude: 2.2)
        let output = generator.reverberateWithCombFilter(reverbDuration: 1.1, loopDuration: 1.2)
        XCTAssertEqual(output.sporth, #""ak" "0" gen_vals 1.1 2.2 sine 0 "ak" tset 0 "ak" tget 1.1 1.2 comb "#)
    }

    func testReverberateWithCostello() {
        let generator = Operation.sineWave(frequency: 1.1, amplitude: 2.2)
        let output = generator.reverberateWithCostello(feedback: 0.8, cutoffFrequency: 1000)
        XCTAssertEqual(output.sporth, #""ak" "" gen_vals 1.1 2.2 sine  1.1 2.2 sine   0.8 1000.0 revsc "#)
    }

    func testReverberateWithFlatFrequencyResponse() {
        let generator = Operation.sineWave(frequency: 1.1, amplitude: 2.2)
        let output = generator.reverberateWithFlatFrequencyResponse(reverbDuration: 1.1, loopDuration: 1.2)
        XCTAssertEqual(output.sporth, #""ak" "0" gen_vals 1.1 2.2 sine 0 "ak" tset 0 "ak" tget 1.1 1.2 allpass "#)
    }

    func testSave() {
        let operation = Operation.sineWave().save(parameterIndex: 7)
        XCTAssertEqual(operation.sporth, #""ak" "0" gen_vals 440.0 1.0 sine 0 "ak" tset 0 "ak" tget dup 7 pset "#)
    }

    func testSawtooth() {
        let operation = Operation.sawtooth(frequency: 1.1, amplitude: 1.2, phase: 0.1)
        XCTAssertEqual(operation.sporth, #""sawtooth" 4096 "0 -1 4095 1" gen_line 1.1 1.2 0.1 "sawtooth" osc "#)
    }

    func testSawtoothWave() {
        let operation = Operation.sawtoothWave(frequency: 220, amplitude: 0.8)
        XCTAssertEqual(operation.sporth, "220.0 0.8 blsaw ")
    }

    func testScale() {
        let operation = Operation.sineWave().scale(minimum: 0.7, maximum: 0.9)
        XCTAssertEqual(operation.sporth, #""ak" "0" gen_vals 440.0 1.0 sine 0 "ak" tset 0 "ak" tget 0.7 0.9 biscale "#)
    }

    func testScaledBy() {
        let operation = Operation.sineWave().scaledBy(0.9)
        XCTAssertEqual(operation.sporth, #""ak" "0" gen_vals 440.0 1.0 sine 0 "ak" tset 0 "ak" tget 0.9 * "#)
    }

    func testSineWave() {
        let operation = Operation.sineWave(frequency: 1.1, amplitude: 2.2)
        XCTAssertEqual(operation.sporth, "1.1 2.2 sine ")
    }

    func testSmoothDelay() {
        let generator = Operation.sineWave(frequency: 1.1, amplitude: 2.2)
        let output = generator.smoothDelay(time: 1.1, feedback: 0.8, samples: 256, maximumDelayTime: 1.9)
        XCTAssertEqual(output.sporth, #""ak" "0" gen_vals 1.1 2.2 sine 0 "ak" tset 0 "ak" tget 0.8 1.1 1.9 256.0 smoothdelay "#)
    }

    func testSquare() {
        let operation = Operation.square(frequency: 1.1, amplitude: 1.2, phase: 0.1)
        XCTAssertEqual(operation.sporth, #""square" 4096 "0 -1 2047 -1 2048 1 4095 1" gen_line 1.1 1.2 0.1 "square" osc "#)
    }

    func testSquareWave() {
        let operation = Operation.squareWave(frequency: 220, amplitude: 0.8)
        XCTAssertEqual(operation.sporth, "220.0 0.8 0.5 blsquare ")
    }

    func testSubtract() {
        let operation1 = Operation.sineWave()
        let operation2 = Operation.squareWave()
        let difference = operation1 - operation2
        XCTAssertEqual(difference.sporth, #""ak" "0 0" gen_vals 440.0 1.0 sine 0 "ak" tset 440.0 1.0 0.5 blsquare 1 "ak" tset 0 "ak" tget 1 "ak" tget - "#)
    }

    func testTrackedAmplitude() {
        let operation = Operation.sineWave().trackedAmplitude(Operation.parameters[7])
        XCTAssertEqual(operation.sporth, #""ak" "0" gen_vals 440.0 1.0 sine 0 "ak" tset 0 "ak" tget rms "#)
    }

    func testTriangle() {
        let operation = Operation.triangle(frequency: 1.1, amplitude: 1.2, phase: 0.1)
        XCTAssertEqual(operation.sporth, #""triangle" 4096 "0 -1 2048 1 4096 -1" gen_line 1.1 1.2 0.1 "triangle" osc "#)
    }

    func testTriangleWave() {
        let operation = Operation.triangleWave(frequency: 220, amplitude: 0.8)
        XCTAssertEqual(operation.sporth, "220.0 0.8 bltriangle ")
    }

    func testVariableDelay() {
        let generator = Operation.sineWave(frequency: 1.1, amplitude: 2.2)
        let output = generator.variableDelay(time: 1.1, feedback: 0.8, maximumDelayTime: 1.9)
        XCTAssertEqual(output.sporth, #""ak" "0" gen_vals 1.1 2.2 sine 0 "ak" tset 0 "ak" tget 0.8 1.1 1.9 vdelay "#)
    }

    func testWhiteNoise() {
        let operation = Operation.whiteNoise(amplitude: 0.9)
        XCTAssertEqual(operation.sporth, "0.9 noise ")
    }
}
