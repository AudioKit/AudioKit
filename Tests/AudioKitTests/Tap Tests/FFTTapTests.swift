// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class FFTTapTests: AKTestCase {
    func check(values: [Int], known: [Int]) {
        XCTAssertGreaterThanOrEqual(values.count, known.count)
        if values.count >= known.count {
            for i in 0 ..< known.count {
                XCTAssertEqual(values[i], known[i])
            }
        }
    }

    func testFFT() {
        let engine = AudioEngine()

        let oscillator = TestOscillator()
        let mixer = Mixer(oscillator)

        var fftData: [Int] = []

        let expect = expectation(description: "wait for buckets")
        let targetFrequencies: [Float] = [88, 258, 433, 605, 777, 949, 1122, 1294, 1467, 1639]
        let expectedBuckets: [Int] = [8, 24, 40, 56, 72, 88, 104, 120, 136, 152]

        let tap = Tap(mixer, bufferSize: 4096) { leftData, _ in

            let fft = performFFT(data: leftData,
                                 isNormalized: true,
                                 zeroPaddingFactor: 0)

            let max: Float = fft.max() ?? 0.0
            let index = Int(fft.firstIndex(of: max) ?? 0)

            // Only store when the max-amplitude frequency changes.
            if !fftData.contains(index) {
                fftData.append(index)
                if fftData.count == targetFrequencies.count {
                    expect.fulfill()
                }
            }
        }

        engine.output = mixer

        let audio = engine.startTest(totalDuration: 10.0)
        for targetFrequency in targetFrequencies {
            oscillator.frequency = targetFrequency
            audio.append(engine.render(duration: 1.0))
        }

        wait(for: [expect], timeout: 10.0)
        engine.stop()
        XCTAssertNotNil(tap)
        check(values: fftData, known: expectedBuckets)
    }

    @available(iOS 13.0, *)
    func testZeroPadding() {
        // XXX: turned off for CI
        return
        let paddingFactor = 7

        let engine = AudioEngine()

        let oscillator = TestOscillator()

        var fftData: [Int] = []

        let expect = expectation(description: "wait for buckets")
        let targetFrequencies: [Float] = [88, 258, 433, 605, 777, 949, 1122, 1294, 1467, 1639]
        let expectedBuckets: [Int] = [8, 23, 24, 40, 56, 72, 88, 104, 120, 136, 152]

        let tap = Tap(oscillator, bufferSize: 4096) { leftData, _ in

            let fft = performFFT(data: leftData,
                                 isNormalized: true,
                                 zeroPaddingFactor: 7)

            let max: Float = fft.max() ?? 0.0
            let index = Int(fft.firstIndex(of: max) ?? 0) / (paddingFactor + 1)
            if !fftData.contains(index) {
                fftData.append(index)
                if fftData.count == targetFrequencies.count {
                    expect.fulfill()
                }
            }
        }
        engine.output = oscillator

        let audio = engine.startTest(totalDuration: 10.0)
        for targetFrequency in targetFrequencies {
            oscillator.frequency = targetFrequency
            audio.append(engine.render(duration: 1.0))
        }

        wait(for: [expect], timeout: 10.0)
        engine.stop()
        XCTAssertNotNil(tap)
        check(values: fftData, known: expectedBuckets)
    }
}
