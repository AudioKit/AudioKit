// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AmplitudeTapTests: XCTestCase {

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
        for i in 0..<knownValues.count {
            XCTAssertEqual(amplitudes[i], knownValues[i], accuracy: 0.001)
        }
    }

}
