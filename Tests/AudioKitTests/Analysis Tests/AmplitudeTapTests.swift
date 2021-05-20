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
        print(values)
    }

    func testDefault() {

        let engine = AudioEngine()

        var amplitudes: [Float] = []

        let oscillator = Oscillator(waveform: Table(.triangle), amplitude: 0.0)
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

        let knownValues: [Float] = [0.0077754078, 0.020305527, 0.03402313, 0.046660095, 0.060981415, 0.073363975, 0.08749893, 0.10062352, 0.113436826, 0.12835906, 0.1396086, 0.15564352, 0.16636369, 0.18197545, 0.19400212, 0.20717761, 0.2225422, 0.23275706, 0.25036314, 0.259291, 0.2767475, 0.28709638, 0.30134922, 0.31633607, 0.32613516, 0.34495628, 0.35221478, 0.37169117, 0.37995663, 0.39603046, 0.4096301, 0.4198146, 0.4392988, 0.445231, 0.4666716, 0.47266597, 0.49116957, 0.5024529]
        check(values: amplitudes, known: knownValues)
    }

    func testLeftStereoMode() {

        let engine = AudioEngine()

        var amplitudes: [Float] = []

        let oscillator = Oscillator(waveform: Table(.triangle), amplitude: 0.0)
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

        let knownValues: [Float] = [0.0077754078, 0.020305527, 0.03402313, 0.046660095, 0.060981415, 0.073363975, 0.08749893, 0.10062352, 0.113436826, 0.12835906, 0.1396086, 0.15564352, 0.16636369, 0.18197545, 0.19400212, 0.20717761, 0.2225422, 0.23275706, 0.25036314, 0.259291, 0.2767475, 0.28709638, 0.30134922, 0.31633607, 0.32613516, 0.34495628, 0.35221478, 0.37169117, 0.37995663, 0.39603046, 0.4096301, 0.4198146, 0.4392988, 0.445231, 0.4666716, 0.47266597, 0.49116957, 0.5024529]
        check(values: amplitudes, known: knownValues)
    }

    func testRightStereoMode() {

        let engine = AudioEngine()

        var amplitudes: [Float] = []

        let oscillator = Oscillator(waveform: Table(.triangle), amplitude: 0.0)
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

        let knownValues: [Float] = [0.0077754078, 0.020305527, 0.03402313, 0.046660095, 0.060981415, 0.073363975, 0.08749893, 0.10062352, 0.113436826, 0.12835906, 0.1396086, 0.15564352, 0.16636369, 0.18197545, 0.19400212, 0.20717761, 0.2225422, 0.23275706, 0.25036314, 0.259291, 0.2767475, 0.28709638, 0.30134922, 0.31633607, 0.32613516, 0.34495628, 0.35221478, 0.37169117, 0.37995663, 0.39603046, 0.4096301, 0.4198146, 0.4392988, 0.445231, 0.4666716, 0.47266597, 0.49116957, 0.5024529]
        check(values: amplitudes, known: knownValues)
    }

    func testPeakAnalysisMode() {

        let engine = AudioEngine()

        var amplitudes: [Float] = []

        let oscillator = Oscillator(waveform: Table(.triangle), amplitude: 0.0)
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

        let knownValues: [Float] = [0.021451602, 0.043550525, 0.069117166, 0.09131404, 0.11261419, 0.13607895, 0.16094965, 0.1816103, 0.20613617, 0.23020686, 0.2501777, 0.27642027, 0.30003104, 0.31984532, 0.3415347, 0.36791936, 0.3892861, 0.41163027, 0.4388137, 0.46003014, 0.48195264, 0.5099348, 0.5300527, 0.5495149, 0.5737703, 0.59945524, 0.6187608, 0.64470285, 0.6686309, 0.68777996, 0.7158623, 0.7375797, 0.7592407, 0.7803229, 0.8090585, 0.83042043, 0.84937406, 0.88053244]
        check(values: amplitudes, known: knownValues)
    }

}
