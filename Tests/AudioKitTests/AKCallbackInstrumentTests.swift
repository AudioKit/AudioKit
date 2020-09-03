// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit

class AKCallbackInstrumentTests: AKTestCase {

    var instrument = AKCallbackInstrument()

    func getTestSequence() -> AKSequence {

        var seq = AKSequence()
        seq.add(noteNumber: 60, position: 0, duration: 0.5)
        seq.add(noteNumber: 62, position: 1, duration: 0.5)
        seq.add(noteNumber: 63, position: 2, duration: 0.5)

        return seq
    }

    func testDefault() {

        duration = 3

        let expect = XCTestExpectation(description: "wait for callback")
        let expectedData: [UInt8] = [144, 60, 127,
                                     128, 60, 127,
                                     144, 62, 127,
                                     128, 62, 127,
                                     144, 63, 127,
                                     128, 63, 127]

        var data: [UInt8] = []

        instrument = AKCallbackInstrument() { status, data1, data2 in
            data.append(status)
            data.append(data1)
            data.append(data2)

            if data.count == expectedData.count {
                expect.fulfill()
            }
        }

        let track = AKSequencerTrack(targetNode: instrument)
        track.sequence = getTestSequence()
        track.loopEnabled = false
        track.playFromStart()

        engine.output = instrument

        AKTest()

        wait(for: [expect], timeout: 1.0)
        XCTAssertEqual(data, expectedData)
    }


}
