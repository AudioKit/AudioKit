// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
#if !os(tvOS)

import XCTest
import AudioKit
import AudioKitEX

class CallbackInstrumentTests: XCTestCase {

    var instrument = CallbackInstrument()

    func testDefault() {
        let engine = AudioEngine()

        let expect = XCTestExpectation(description: "wait for callback")
        let expectedData = [MIDIEvent(noteOn: 60, velocity: 127, channel: 0),
                            MIDIEvent(noteOn: 61, velocity: 127, channel: 0),
                            MIDIEvent(noteOn: 62, velocity: 127, channel: 0)]

        var data: [MIDIEvent] = []

        instrument = CallbackInstrument { status, data1, data2 in

            data.append(MIDIEvent(data: [status, data1, data2]))

            if data.count == expectedData.count {
                expect.fulfill()
            }
        }

        engine.output = instrument

        for event in expectedData {
            instrument.scheduleMIDIEvent(event: event)
        }

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

        engine.output = instrument

        let audio = engine.startTest(totalDuration: 3.0)
        audio.append(engine.render(duration: 3.0))

        wait(for: [expect], timeout: 1.0)
        /// If the callback does get called, this will fail our test, adding insult to injury
        XCTAssertEqual(data, expectedData)
    }
}
#endif
