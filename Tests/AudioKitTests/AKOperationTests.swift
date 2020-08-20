// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
@testable import AudioKit

class AKOperationTests: XCTestCase {

    func testBitCrush() {
        let generator = AKOperation.sineWave(frequency: 1.1, amplitude: 2.2)
        let output = generator.bitCrush(bitDepth: 8, sampleRate: 8000)
        XCTAssertEqual(output.sporth, #""ak" "0" gen_vals 1.1 2.2 sine 0 "ak" tset 0 "ak" tget 8.0 8000.0 bitcrush "#)
    }

    func testBrownianNoise() {
        let operation = AKOperation.brownianNoise(amplitude: 0.9)
        XCTAssertEqual(operation.sporth, "0.9 brown * ")
    }

    func testClip() {
        let generator = AKOperation.sineWave(frequency: 1.1, amplitude: 2.2)
        let output = generator.clip(0.7)
        XCTAssertEqual(output.sporth, #""ak" "0" gen_vals 1.1 2.2 sine 0 "ak" tset 0 "ak" tget 0.7 clip "#)
    }

    func testDelay() {
        let generator = AKOperation.sineWave(frequency: 1.1, amplitude: 2.2)
        let output = generator.delay(time: 1.2, feedback: 0.8)
        XCTAssertEqual(output.sporth, #""ak" "0" gen_vals 1.1 2.2 sine 0 "ak" tset 0 "ak" tget 0.8 1.2 delay "#)
    }

    func testDistort() {
        let generator = AKOperation.sineWave(frequency: 1.1, amplitude: 2.2)
        let output = generator.distort(pregain: 0.6, postgain: 1.5, positiveShapeParameter: 0.7, negativeShapeParameter: 0.8)
        XCTAssertEqual(output.sporth, #""ak" "0" gen_vals 1.1 2.2 sine 0 "ak" tset 0 "ak" tget 0.6 1.5 0.7 0.8 dist "#)
    }

    func testFMOscillator() {
        let operation = AKOperation.fmOscillator(baseFrequency: 220, carrierMultiplier: 1.1, modulatingMultiplier: 1.2, modulationIndex: 1.3, amplitude: 1.4)
        XCTAssertEqual(operation.sporth, "220.0 1.4 1.1 1.2 1.3 fm ")
    }

    func testMorphingOscillator() {
        let operation = AKOperation.morphingOscillator(frequency: 220, amplitude: 0.8, index: 2)
        XCTAssertEqual(operation.sporth, #""sine" 4096 gen_sine  "square" 4096 "0 1 2047 1 2048 -1 4095 -1" gen_line  "sawtooth" 4096 "0 -1 4095 1" gen_line  "revsaw" 4096 "0 1 4095 -1" gen_line 220.0 0.8 2.0 3 / 0 "sine" "square" "sawtooth" "revsaw" oscmorph4 "#)
    }

    func testPhasor() {
        let operation = AKOperation.phasor(frequency: 1.1, phase: 0.1)
        XCTAssertEqual(operation.sporth, "1.1 0.1 phasor ")
    }

    func testPinkNoise() {
        let operation = AKOperation.pinkNoise(amplitude: 0.9)
        XCTAssertEqual(operation.sporth, "0.9 pinknoise ")
    }

    func testSawtooth() {
        let operation = AKOperation.sawtooth(frequency: 1.1, amplitude: 1.2, phase: 0.1)
        XCTAssertEqual(operation.sporth, #""sawtooth" 4096 "0 -1 4095 1" gen_line1.1 1.2 0.1 "sawtooth" osc "#)
    }

    func testSawtoothWave() {
        let operation = AKOperation.sawtoothWave(frequency: 220, amplitude: 0.8)
        XCTAssertEqual(operation.sporth, "220.0 0.8 blsaw ")
    }

    func testSineWave() {
        let operation = AKOperation.sineWave(frequency: 1.1, amplitude: 2.2)
        XCTAssertEqual(operation.sporth, "1.1 2.2 sine ")
    }

    func testSmoothDelay() {
        let generator = AKOperation.sineWave(frequency: 1.1, amplitude: 2.2)
        let output = generator.smoothDelay(time: 1.1, feedback: 0.8, samples: 256, maximumDelayTime: 1.9)
        XCTAssertEqual(output.sporth, #""ak" "0" gen_vals 1.1 2.2 sine 0 "ak" tset 0 "ak" tget 0.8 1.1 1.9 256.0 smoothdelay "#)
    }

    func testSquare() {
        let operation = AKOperation.square(frequency: 1.1, amplitude: 1.2, phase: 0.1)
        XCTAssertEqual(operation.sporth, #""square" 4096 "0 -1 2047 -1 2048 1 4095 1" gen_line1.1 1.2 0.1 "square" osc "#)
    }

    func testSquareWave() {
        let operation = AKOperation.squareWave(frequency: 220, amplitude: 0.8)
        XCTAssertEqual(operation.sporth, "220.0 0.8 0.5 blsquare ")
    }

    func testTriangle() {
        let operation = AKOperation.triangle(frequency: 1.1, amplitude: 1.2, phase: 0.1)
        XCTAssertEqual(operation.sporth, #""triangle" 4096 "0 -1 2048 1 4096 -1" gen_line1.1 1.2 0.1 "triangle" osc "#)
    }

    func testTriangleWave() {
        let operation = AKOperation.triangleWave(frequency: 220, amplitude: 0.8)
        XCTAssertEqual(operation.sporth, "220.0 0.8 bltriangle ")
    }

    func testVariableDelay() {
        let generator = AKOperation.sineWave(frequency: 1.1, amplitude: 2.2)
        let output = generator.variableDelay(time: 1.1, feedback: 0.8, maximumDelayTime: 1.9)
        XCTAssertEqual(output.sporth, #""ak" "0" gen_vals 1.1 2.2 sine 0 "ak" tset 0 "ak" tget 0.8 1.1 1.9 vdelay "#)
    }

    func testWhiteNoise() {
        let operation = AKOperation.whiteNoise(amplitude: 0.9)
        XCTAssertEqual(operation.sporth, "0.9 noise ")
    }
}
