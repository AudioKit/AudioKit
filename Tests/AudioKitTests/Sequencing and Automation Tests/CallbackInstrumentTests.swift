// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
#if !os(tvOS)

import XCTest
import AudioKit

class CallbackInstrumentTests: XCTestCase {

    var instrument = CallbackInstrument()

    func getTestSequence() -> NoteEventSequence {
        var seq = NoteEventSequence()
        seq.add(noteNumber: 60, position: 0, duration: 0.5)
        seq.add(noteNumber: 62, position: 1, duration: 0.5)
        seq.add(noteNumber: 63, position: 2, duration: 0.5)
        return seq
    }
    
    func getEmptyTestSequence() -> NoteEventSequence {
        return NoteEventSequence()
    }

    func testDefault() {
        let engine = AudioEngine()

        let expect = XCTestExpectation(description: "wait for callback")
        let expectedData: [MIDIByte] = [144, 60, 127,
                                        128, 60, 127,
                                        144, 62, 127,
                                        128, 62, 127,
                                        144, 63, 127,
                                        128, 63, 127]

        var data: [MIDIByte] = []

        instrument = CallbackInstrument { status, data1, data2 in
            data.append(status)
            data.append(data1)
            data.append(data2)

            if data.count == expectedData.count {
                expect.fulfill()
            }
        }

        let track = SequencerTrack(targetNode: instrument)
        track.sequence = getTestSequence()
        track.loopEnabled = false
        track.playFromStart()

        engine.output = instrument

        let audio = engine.startTest(totalDuration: 3.0)
        audio.append(engine.render(duration: 3.0))

        wait(for: [expect], timeout: 1.0)
        XCTAssertEqual(data, expectedData)
    }
    
    func testEmptySequence() {
        let engine = AudioEngine()

        let expect = XCTestExpectation(description: "callback should not be called")
        /// No matter the expected data, the callback should not be called
        expect.isInverted = true
        let expectedData: [MIDIByte] = []
        var data: [MIDIByte] = []
        
        instrument = CallbackInstrument { status, data1, data2 in
            XCTFail("this callback should not be called")
            data.append(status)
            data.append(data1)
            data.append(data2)
        }

        let track = SequencerTrack(targetNode: instrument)
        track.sequence = getEmptyTestSequence()
        track.loopEnabled = false
        track.playFromStart()

        engine.output = instrument

        let audio = engine.startTest(totalDuration: 3.0)
        audio.append(engine.render(duration: 3.0))

        wait(for: [expect], timeout: 1.0)
        /// If the callback does get called, this will fail our test, adding insult to injury
        XCTAssertEqual(data, expectedData)
    }
}
#endif
