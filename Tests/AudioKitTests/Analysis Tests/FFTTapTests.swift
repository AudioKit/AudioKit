// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class FFTTapTests: XCTestCase {

    func check(values: [Int], known: [Int]) {
        XCTAssertGreaterThanOrEqual(values.count, known.count)
        if values.count >= known.count {
            for i in 0..<known.count {
                XCTAssertEqual(values[i], known[i])
            }
        }
    }

    func testBasic() {
        let engine = AudioEngine()

        let oscillator = Oscillator(waveform: Table(.triangle), frequency: 1)
        engine.output = oscillator
        oscillator.start()
        oscillator.$frequency.ramp(to: 20000, duration: 1.0)

        var fftData: [Int] = []

        let expect = expectation(description: "wait for amplitudes")
        let knownValues: [Int] = [88, 258, 433, 605, 777, 949, 1122, 1294, 1467, 1639]

        let tap = FFTTap(oscillator) { fft in
            let max: Float = fft.max() ?? 0.0
            let index = Int(fft.firstIndex(of: max) ?? 0)
            fftData.append(index)

            if fftData.count == knownValues.count {
                expect.fulfill()
            }
        }
        tap.start()

        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)

        wait(for: [expect], timeout: 5.0)

        check(values: fftData, known: knownValues)
    }

    func testWithoutNormalization() {
        let engine = AudioEngine()

        let oscillator = Oscillator(waveform: Table(.triangle), frequency: 1)
        engine.output = oscillator
        oscillator.start()
        oscillator.$frequency.ramp(to: 20000, duration: 1.0)

        var fftData: [Int] = []

        let expect = expectation(description: "wait for amplitudes")
        let numValuesToCheck = 10

        let tap = FFTTap(oscillator) { fft in
            let max: Float = fft.max() ?? 0.0
            fftData.append(Int(max))

            if fftData.count == numValuesToCheck {
                expect.fulfill()
            }
        }
        tap.isNormalized = false
        tap.start()

        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)

        wait(for: [expect], timeout: 5.0)

        for i in 0..<fftData.count {
            XCTAssertTrue(fftData[i] > 1)
        }
    }

    func testWithZeroPadding() {
        let engine = AudioEngine()

        let oscillator = Oscillator(waveform: Table(.triangle), frequency: 1)
        engine.output = oscillator
        oscillator.start()
        oscillator.$frequency.ramp(to: 20000, duration: 1.0)

        var fftData: [Int] = []

        let expect = expectation(description: "wait for amplitudes")
        let knownValues: [Int] = [20, 694, 1039, 1384, 1729, 2071, 2418, 2763, 3109, 3453]

        let tap = FFTTap(oscillator) { fft in
            let max: Float = fft.max() ?? 0.0
            let index = Int(fft.firstIndex(of: max) ?? 0)
            fftData.append(index)

            if fftData.count == knownValues.count {
                expect.fulfill()
            }
        }
        tap.zeroPaddingFactor = 1
        tap.start()

        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)

        wait(for: [expect], timeout: 5.0)

        check(values: fftData, known: knownValues)
    }
}
