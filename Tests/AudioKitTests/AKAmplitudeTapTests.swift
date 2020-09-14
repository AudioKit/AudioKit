// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKAmplitudeTapTests: XCTestCase {

    func testDefault() {

        let engine = AKEngine()

        var amplitudes: [Float] = []

        let sine = AKOperationGenerator {
            let amplitude = AKOperation.sineWave(frequency: 0.25, amplitude: 1)
            return AKOperation.sineWave() * amplitude }

        engine.output = sine
        sine.start()

        let expect = expectation(description: "wait for amplitudes")

        let tap = AKAmplitudeTap(sine) { amp in
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

        let knownValues: [Float] = [0.06389575, 0.16763051, 0.27164128, 0.36971274, 0.458969,
                                    0.53708506, 0.6020897, 0.6523612, 0.6866519, 0.70411265]
        for i in 0..<knownValues.count {
            XCTAssertEqual(amplitudes[i], knownValues[i], accuracy: 0.001)
        }
    }

}
