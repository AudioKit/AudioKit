// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit

class AKCallbackInstrumentTests: AKTestCase {

    let instrument = AKCallbackInstrument()

    func getTestSequence() -> AKSequence {

        var seq = AKSequence()
        seq.add(noteNumber: 60, position: 0, duration: 0.5)
        seq.add(noteNumber: 62, position: 1, duration: 0.5)
        seq.add(noteNumber: 63, position: 2, duration: 0.5)

        return seq
    }

    func testDefault() {

        duration = 3

        let track = AKSequencerTrack(targetNode: instrument)
        var data: [UInt8] = []
        instrument.callback = { status, data1, data2 in
            data.append(status)
            data.append(data1)
            data.append(data2)
        }

        track.sequence = getTestSequence()
        track.loopEnabled = false
        track.playFromStart()

        output = instrument

        AKTestMD5("1d479b2f01ff096f729486321207710c")
        XCTAssertEqual(data, [144, 60, 127,
                              128, 60, 127,
                              144, 62, 127,
                              128,62, 127,
                              144, 63, 127,
                              128,  63, 127])
    }


}
