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

    func testPinkNoise() {
        let operation = AKOperation.pinkNoise(amplitude: 0.9)
        XCTAssertEqual(operation.sporth, "0.9 pinknoise ")
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
