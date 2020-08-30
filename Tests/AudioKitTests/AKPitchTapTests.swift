// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKPitchTapTests: AKTestCase2 {

    var tap: AKPitchTap!
    var pitches: [Float] = []

    let sine = AKOperationGenerator {
        let s = AKOperation.sawtooth(frequency: 0.25, amplitude: 1, phase: 0) + 2
        return AKOperation.sineWave(frequency: 440 * s, amplitude: 1)
    }

    override func setUp() {
        afterStart = { self.sine.start() }
        duration = 1.0
    }

    func testBasic() {
        output = sine
        tap = AKPitchTap(sine) {  [weak self] (pitches, _) in
            self?.pitches.append(pitches[0])
        }
        tap.start()
        AKTest()

        let knownValues: [Float] = [447.32297, 455.59183, 481.56384, 497.71292, 519.39923, 542.7518, 555.37006, 583.9163, 602.96344, 621.56274]
        for i in 0..<knownValues.count {
            // TODO
//            XCTAssertEqual(pitches[i], knownValues[i], accuracy: 0.001)
        }
    }

}
