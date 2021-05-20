// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class PitchTapTests: XCTestCase {

    func testBasic() {
        let engine = AudioEngine()

        let oscillator = Oscillator(frequency: 440)
        engine.output = oscillator
        oscillator.start()
        oscillator.$frequency.ramp(to: 660, duration: 1.0)

        var pitches: [Float] = []
        let knownValues: [Float] = [100.0, 447.32437, 455.5944, 481.5628, 497.71658, 517.4379, 542.6506, 555.4854, 581.54614, 597.6265]

        let expect = expectation(description: "wait for amplitudes")

        let tap = PitchTap(oscillator) {  (tapPitches, _) in
            pitches.append(tapPitches[0])

            if pitches.count == knownValues.count {
                expect.fulfill()
            }
        }
        tap.start()

        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)

        wait(for: [expect], timeout: 5.0)

        for i in 0..<knownValues.count {
            XCTAssertEqual(pitches[i], knownValues[i], accuracy: 0.001)
        }
    }

}
