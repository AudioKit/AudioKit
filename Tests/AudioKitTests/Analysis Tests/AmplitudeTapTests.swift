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

        let sine = OperationGenerator {
            let amplitude = Operation.sineWave(frequency: 0.25, amplitude: 1)
            return Operation.sineWave() * amplitude }

        engine.output = sine
        sine.start()

        let expect = expectation(description: "wait for amplitudes")

        let tap = AmplitudeTap(sine) { amp in
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

        let knownValues: [Float] = [0.01478241, 0.03954828, 0.06425185, 0.09090047, 0.11480384,
                                    0.14164367, 0.16560285, 0.19081590, 0.21635467, 0.23850754]
        check(values: amplitudes, known: knownValues)
    }

    func testLeftStereoMode() {

        let engine = AudioEngine()

        var amplitudes: [Float] = []

        let sine = OperationGenerator {
            let amplitude = Operation.sineWave(frequency: 0.25, amplitude: 1)
            return Operation.sineWave() * amplitude }

        engine.output = sine
        sine.start()

        let expect = expectation(description: "wait for amplitudes")

        let tap = AmplitudeTap(sine) { amp in
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

        let knownValues: [Float] = [0.01478241, 0.03954828, 0.06425185, 0.09090047, 0.11480384,
                                    0.14164367, 0.16560285, 0.19081590, 0.21635467, 0.23850754]
        check(values: amplitudes, known: knownValues)
    }

    func testRightStereoMode() {

        let engine = AudioEngine()

        var amplitudes: [Float] = []

        let sine = OperationGenerator {
            let amplitude = Operation.sineWave(frequency: 0.25, amplitude: 1)
            return Operation.sineWave() * amplitude }

        engine.output = sine
        sine.start()

        let expect = expectation(description: "wait for amplitudes")

        let tap = AmplitudeTap(sine) { amp in
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

        let knownValues: [Float] = [0.01478241, 0.03954828, 0.06425185, 0.09090047, 0.11480384,
                                    0.14164367, 0.16560285, 0.19081590, 0.21635467, 0.23850754]
        check(values: amplitudes, known: knownValues)
    }

    func testPeakAnalysisMode() {

        let engine = AudioEngine()

        var amplitudes: [Float] = []

        let sine = OperationGenerator {
            let amplitude = Operation.sineWave(frequency: 0.25, amplitude: 1)
            return Operation.sineWave() * amplitude }

        engine.output = sine
        sine.start()

        let expect = expectation(description: "wait for amplitudes")

        let tap = AmplitudeTap(sine) { amp in
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

        let knownValues: [Float] = [0.03505735, 0.07213809, 0.10766032, 0.1430245, 0.17815503,
                                    0.2166785, 0.251323, 0.2855623, 0.3196378, 0.3532541]
        check(values: amplitudes, known: knownValues)
    }

}
