//
//  AKSequencerEngineTests.swift
//  AudioKitGen
//
//  Created by Taylor Holliday on 8/2/20.
//

import XCTest
import AudioKit

class AKSequencerEngineTests: XCTestCase {

    func observerTest(sequence: AKSequence) -> [AKMIDIEvent] {

        let engine = AKSequencerEngineCreate()

        let settings = AKSequenceSettings(maximumPlayCount: 1,
                                          length: 4,
                                          tempo: 120,
                                          loopEnabled: false,
                                          numberOfLoops: 0)

        var events = [AKMIDIEvent]()

        let block: AUScheduleMIDIEventBlock = { (sampleTime, cable, length, midiBytes) in

            var bytes = [MIDIByte]()
            for index in 0 ..< length {
                bytes.append(midiBytes[index])
            }
            events.append(AKMIDIEvent(data: bytes, offset: MIDITimeStamp(sampleTime)))

        }

        sequence.events.withUnsafeBufferPointer { (eventsPtr: UnsafeBufferPointer<AKSequenceEvent>) -> Void in
            sequence.notes.withUnsafeBufferPointer { (notesPtr: UnsafeBufferPointer<AKSequenceNote>) -> Void in
                let observer = AKSequencerEngineUpdateSequence(engine,
                                                               eventsPtr.baseAddress,
                                                               sequence.events.count,
                                                               notesPtr.baseAddress,
                                                               sequence.notes.count,
                                                               settings,
                                                               44100,
                                                               block)!

                var timeStamp = AudioTimeStamp()
                timeStamp.mSampleTime = 0

                observer(.unitRenderAction_PreRender, &timeStamp, 44100, 0)

            }
        }

        AKSequencerEngineDestroy(engine)

        return events
    }

    func testBasicSequence() {

        var seq = AKSequence()

        seq.add(noteNumber: 60, position: 0.5, duration: 0.1)

        let events = observerTest(sequence: seq)

        XCTAssertEqual(events.count, 2)
        XCTAssertEqual(events[0].noteNumber!, 60)
        XCTAssertEqual(events[0].status!.type, .noteOn)
        XCTAssertEqual(events[0].offset, 11025)
        XCTAssertEqual(events[1].noteNumber!, 60)
        XCTAssertEqual(events[1].status!.type, .noteOff)
        XCTAssertEqual(events[1].offset, 13230)
    }

}
