// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit
import AVFAudio

class AmplitudeTapTests: XCTestCase {

    func check(values: [Float], known: [Float]) {
        if values.count >= known.count {
            for i in 0..<known.count {
                XCTAssertEqual(values[i], 0.579 * known[i], accuracy: 0.03)
            }
        }
    }

    @available(iOS 13.0, *)
    func testDefault() {

        let engine = Engine()

        var detectedAmplitudes: [Float] = []
        let targetAmplitudes: [Float] = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]

        let noise = PlaygroundNoiseGenerator(amplitude: 0.0)
        engine.output = noise

        let expect = expectation(description: "wait for amplitudes")

        let tap = AmplitudeTap(noise) { amp in
            if abs(amp - (detectedAmplitudes.last ?? 0.0)) > 0.05 {
                detectedAmplitudes.append(amp)
                if detectedAmplitudes.count == 10 {
                    expect.fulfill()
                }
            }

        }
        tap.start()

        let audio = engine.startTest(totalDuration: 10.0)
        for amplitude in targetAmplitudes {
            noise.amplitude = amplitude
            audio.append(engine.render(duration: 1.0))
        }
        wait(for: [expect], timeout: 10.0)

        check(values: detectedAmplitudes, known: targetAmplitudes)

    }


}
