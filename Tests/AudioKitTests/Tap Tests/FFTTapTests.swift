// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class FFTTapTests: XCTestCase {
    func check(values: [Int], known: [Int]) {
        XCTAssertGreaterThanOrEqual(values.count, known.count)
        if values.count >= known.count {
            for i in 0 ..< known.count {
                XCTAssertEqual(values[i], known[i])
            }
        }
    }

    func testFFT() {
        let engine = Engine()

        let oscillator = PlaygroundOscillator()
        let mixer = Mixer(oscillator)

        var fftData: [Int] = []

        let expect = expectation(description: "wait for buckets")
        let targetFrequencies: [Float] = [88, 258, 433, 605, 777, 949, 1122, 1294, 1467, 1639]
        let expectedBuckets: [Int] = [8, 24, 40, 56, 72, 88, 104, 120, 136, 152]

        let tap = Tap(mixer, bufferSize: 4096) { leftData, rightData in

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

        engine.output = tap
        oscillator.start()

        let audio = engine.startTest(totalDuration: 10.0)
        for targetFrequency in targetFrequencies {
            oscillator.frequency = targetFrequency
            audio.append(engine.render(duration: 1.0))
        }

        wait(for: [expect], timeout: 10.0)
        check(values: fftData, known: expectedBuckets)
    }

    @available(iOS 13.0, *)
    func testZeroPadding() {
        let paddingFactor = 7

        let engine = AudioEngine()

        let oscillator = PlaygroundOscillator()
        engine.output = oscillator
        oscillator.start()

        var fftData: [Int] = []

        let expect = expectation(description: "wait for buckets")
        let targetFrequencies: [Float] = [88, 258, 433, 605, 777, 949, 1122, 1294, 1467, 1639]
        let expectedBuckets: [Int] = [8, 24, 40, 56, 72, 88, 104, 120, 136, 152]

        let tap = FFTTap(oscillator) { fft in
            let max: Float = fft.max() ?? 0.0
            let index = Int(fft.firstIndex(of: max) ?? 0) / (paddingFactor + 1)
            if !fftData.contains(index) {
                fftData.append(index)
                if fftData.count == targetFrequencies.count {
                    expect.fulfill()
                }
            }
        }
        tap.zeroPaddingFactor = UInt32(paddingFactor)
        tap.start()

        let audio = engine.startTest(totalDuration: 10.0)
        for targetFrequency in targetFrequencies {
            oscillator.frequency = targetFrequency
            audio.append(engine.render(duration: 1.0))
        }

        wait(for: [expect], timeout: 10.0)
        tap.stop()

        check(values: fftData, known: expectedBuckets)
    }
}
