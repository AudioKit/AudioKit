// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class FFTTapTests: XCTestCase {

    func check(values: [Int], known: [Int]) {
        XCTAssertGreaterThanOrEqual(values.count, known.count)
        if values.count > known.count {
            for i in 0..<known.count {
                XCTAssertEqual(values[i], known[i])
            }
        }
    }

    func testBasic() {
        let engine = AudioEngine()

        let sine = OperationGenerator {
            let s = Operation.sawtooth(frequency: 0.25, amplitude: 1, phase: 0) + 2
            return Operation.sineWave(frequency: 440 * s, amplitude: 1)
        }

        sine.start()

        var fftData: [Int] = []

        engine.output = sine

        let expect = expectation(description: "wait for amplitudes")
        let knownValues: [Int] = [42, 44, 46, 48, 49, 51, 53, 55, 57, 59]

        let tap = FFTTap(sine) { fft in
            let max: Float = fft.max() ?? 0.0
            let index = Int(fft.firstIndex(of: max) ?? 0)
            fftData.append(index)

            if fftData.count == knownValues.count {
                expect.fulfill()
            }
        }
        tap.start()

        let audio = engine.startTest(totalDuration: 2.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)

        wait(for: [expect], timeout: 5.0)

        check(values: fftData, known: knownValues)
    }

    func testWithoutNormalization() {
        let engine = AudioEngine()

        let sine = OperationGenerator {
            let s = Operation.sawtooth(frequency: 0.25, amplitude: 1.0, phase: 0) + 2
            return Operation.sineWave(frequency: 440 * s, amplitude: 0.1)
        }

        sine.start()

        var fftData: [Int] = []

        engine.output = sine

        let expect = expectation(description: "wait for amplitudes")
        let numValuesToCheck = 10

        let tap = FFTTap(sine) { fft in
            let max: Float = fft.max() ?? 0.0
            fftData.append(Int(max))

            if fftData.count == numValuesToCheck {
                expect.fulfill()
            }
        }
        tap.isNormalized = false
        tap.start()

        let audio = engine.startTest(totalDuration: 2.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)

        wait(for: [expect], timeout: 5.0)

        for i in 0..<fftData.count {
            XCTAssertTrue(fftData[i] > 1)
        }
    }

    func testWithZeroPadding() {
        let engine = AudioEngine()

        let sine = OperationGenerator {
            let s = Operation.sawtooth(frequency: 0.25, amplitude: 1, phase: 0) + 2
            return Operation.sineWave(frequency: 440 * s, amplitude: 1)
        }

        sine.start()

        var fftData: [Int] = []

        engine.output = sine

        let expect = expectation(description: "wait for amplitudes")
        let knownValues: [Int] = [83, 87, 91, 95, 98, 102, 106, 109, 115, 119]

        let tap = FFTTap(sine) { fft in
            let max: Float = fft.max() ?? 0.0
            let index = Int(fft.firstIndex(of: max) ?? 0)
            fftData.append(index)

            if fftData.count == knownValues.count {
                expect.fulfill()
            }
        }
        tap.zeroPaddingFactor = 1
        tap.start()

        let audio = engine.startTest(totalDuration: 2.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)

        wait(for: [expect], timeout: 5.0)

        check(values: fftData, known: knownValues)
    }
}
