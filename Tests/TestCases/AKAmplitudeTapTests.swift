// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKAmplitudeTapTests: AKTestCase {

    var tap: AKAmplitudeTap!
    var amplitudes: [Float] = []

    let sine = AKOperationGenerator { _ in
        let amplitude = AKOperation.sineWave(frequency: 0.25, amplitude: 1)
        return AKOperation.sineWave() * amplitude }

    override func setUp() {
        afterStart = { self.sine.start() }
        duration = 1.0
    }

    func testDefault() {
        output = sine
        tap = AKAmplitudeTap(sine) { amp in
            self.amplitudes.append(amp)
        }
        tap.start()
        AKTestMD5("82a462832878304dd2b4a11ce62b940e")

        let knownValues: [Float] = [0.06389575, 0.16763051, 0.27164128, 0.36971274, 0.458969,
                                    0.53708506, 0.6020897, 0.6523612, 0.6866519, 0.70411265]
        XCTAssertEqual(amplitudes, knownValues)
    }

}
