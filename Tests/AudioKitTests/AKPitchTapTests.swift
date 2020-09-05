// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKPitchTapTests: XCTestCase {

    func testBasic() {
        let engine = AKEngine()

        let sine = AKOperationGenerator {
            let s = AKOperation.sawtooth(frequency: 0.25, amplitude: 1, phase: 0) + 2
            return AKOperation.sineWave(frequency: 440 * s, amplitude: 1)
        }

        sine.start()

        var tap: AKPitchTap!
        var pitches: [Float] = []

        engine.output = sine

        tap = AKPitchTap(sine) {  (tapPitches, _) in
            pitches.append(tapPitches[0])
        }
        tap.start()

        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)

        let knownValues: [Float] = [447.32297, 455.59183, 481.56384, 497.71292, 519.39923, 542.7518, 555.37006, 583.9163, 602.96344, 621.56274]
        for i in 0..<knownValues.count {
            XCTAssertEqual(pitches[i], knownValues[i], accuracy: 0.001)
        }
    }

}
