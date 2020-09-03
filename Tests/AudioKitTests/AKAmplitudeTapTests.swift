// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKAmplitudeTapTests: AKTestCase {

    override func setUp() {
        duration = 1.0
    }

    func testDefault() {

        var tap: AKAmplitudeTap!
        var amplitudes: [Float] = []

        let sine = AKOperationGenerator {
            let amplitude = AKOperation.sineWave(frequency: 0.25, amplitude: 1)
            return AKOperation.sineWave() * amplitude }

        afterStart = { sine.start() }

        engine.output = sine

        tap = AKAmplitudeTap(sine) { amp in
            amplitudes.append(amp)
        }
        tap.start()

        AKTest()

        let knownValues: [Float] = [0.06389575, 0.16763051, 0.27164128, 0.36971274, 0.458969,
                                    0.53708506, 0.6020897, 0.6523612, 0.6866519, 0.70411265]
        for i in 0..<knownValues.count {
            XCTAssertEqual(amplitudes[i], knownValues[i], accuracy: 0.001)
        }
    }

}
