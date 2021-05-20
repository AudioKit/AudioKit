// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AmplitudeTapTests: XCTestCase {

    func check(values: [Float], known: [Float]) {
        XCTAssertGreaterThan(values.count, known.count)
        if values.count > known.count {
            for i in 0..<known.count {
                XCTAssertEqual(values[i], known[i], accuracy: 0.001)
            }
        }
    }

    func testDefault() {

        let engine = AudioEngine()

        var amplitudes: [Float] = []

        let oscillator = Oscillator(amplitude: 0.0)
        engine.output = oscillator
        oscillator.start()
        oscillator.$amplitude.ramp(to: 1.0, duration: 1.0)

        let expect = expectation(description: "wait for amplitudes")

        let tap = AmplitudeTap(oscillator) { amp in
            amplitudes.append(amp)

            if amplitudes.count == 10 {
                expect.fulfill()
            }
        }
        tap.start()

        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)

        wait(for: [expect], timeout: 5.0)

        let knownValues: [Float] = [0.00942282, 0.025220972, 0.041011177, 0.058098152, 0.07350557, 0.0908917, 0.10654987, 0.12315354, 0.14013591, 0.15510349, 0.17372803, 0.18744196, 0.20658945, 0.2207793, 0.23839833, 0.2550281, 0.26965025, 0.28930312, 0.30145812, 0.32247952, 0.33476913, 0.35403505, 0.36954698, 0.384581, 0.40462023, 0.41562736, 0.43839857, 0.44859052, 0.46998367, 0.48368293, 0.49992698, 0.5195799, 0.53006244, 0.55421007, 0.5623595, 0.58614916, 0.5974768, 0.61569136]
        check(values: amplitudes, known: knownValues)
    }

    func testLeftStereoMode() {

        let engine = AudioEngine()

        var amplitudes: [Float] = []

        let oscillator = Oscillator(amplitude: 0.0)
        engine.output = oscillator
        oscillator.start()
        oscillator.$amplitude.ramp(to: 1.0, duration: 1.0)

        let expect = expectation(description: "wait for amplitudes")

        let tap = AmplitudeTap(oscillator) { amp in
            amplitudes.append(amp)

            if amplitudes.count == 10 {
                expect.fulfill()
            }
        }
        tap.stereoMode = .left
        tap.start()

        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)

        wait(for: [expect], timeout: 5.0)

        let knownValues: [Float] = [0.00942282, 0.025220972, 0.041011177, 0.058098152, 0.07350557, 0.0908917, 0.10654987, 0.12315354, 0.14013591, 0.15510349, 0.17372803, 0.18744196, 0.20658945, 0.2207793, 0.23839833, 0.2550281, 0.26965025, 0.28930312, 0.30145812, 0.32247952, 0.33476913, 0.35403505, 0.36954698, 0.384581, 0.40462023, 0.41562736, 0.43839857, 0.44859052, 0.46998367, 0.48368293, 0.49992698, 0.5195799, 0.53006244, 0.55421007, 0.5623595, 0.58614916, 0.5974768, 0.61569136]
        check(values: amplitudes, known: knownValues)
    }

    func testRightStereoMode() {

        let engine = AudioEngine()

        var amplitudes: [Float] = []

        let oscillator = Oscillator(amplitude: 0.0)
        engine.output = oscillator
        oscillator.start()
        oscillator.$amplitude.ramp(to: 1.0, duration: 1.0)

        let expect = expectation(description: "wait for amplitudes")

        let tap = AmplitudeTap(oscillator) { amp in
            amplitudes.append(amp)

            if amplitudes.count == 10 {
                expect.fulfill()
            }
        }
        tap.stereoMode = .right
        tap.start()

        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)

        wait(for: [expect], timeout: 5.0)

        let knownValues: [Float] = [0.00942282, 0.025220972, 0.041011177, 0.058098152, 0.07350557, 0.0908917, 0.10654987, 0.12315354, 0.14013591, 0.15510349, 0.17372803, 0.18744196, 0.20658945, 0.2207793, 0.23839833, 0.2550281, 0.26965025, 0.28930312, 0.30145812, 0.32247952, 0.33476913, 0.35403505, 0.36954698, 0.384581, 0.40462023, 0.41562736, 0.43839857, 0.44859052, 0.46998367, 0.48368293, 0.49992698, 0.5195799, 0.53006244, 0.55421007, 0.5623595, 0.58614916, 0.5974768, 0.61569136]
        check(values: amplitudes, known: knownValues)
    }

    func testPeakAnalysisMode() {

        let engine = AudioEngine()

        var amplitudes: [Float] = []

        let oscillator = Oscillator(amplitude: 0.0)
        engine.output = oscillator
        oscillator.start()
        oscillator.$amplitude.ramp(to: 1.0, duration: 1.0)

        let expect = expectation(description: "wait for amplitudes")

        let tap = AmplitudeTap(oscillator) { amp in
            amplitudes.append(amp)

            if amplitudes.count == 10 {
                expect.fulfill()
            }
        }
        tap.analysisMode = .peak
        tap.start()

        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)

        wait(for: [expect], timeout: 5.0)

        let knownValues: [Float] = [0.022348743, 0.04601721, 0.06875052, 0.09147034, 0.11415692, 0.13920411, 0.16191694, 0.18457419, 0.20736109, 0.23011333, 0.25499576, 0.27781528, 0.3005661, 0.32322842, 0.34783408, 0.37101626, 0.3936486, 0.41636539, 0.4391955, 0.46405852, 0.48682672, 0.50965476, 0.53233904, 0.55485994, 0.5801122, 0.6027659, 0.62528473, 0.64823896, 0.6731836, 0.69575673, 0.71870834, 0.741461, 0.763995, 0.7891771, 0.81189847, 0.83437896, 0.85721564, 0.8801084]
        check(values: amplitudes, known: knownValues)
    }

}
