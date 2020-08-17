// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit
import CAudioKit
import AVFoundation

class AKSequencerEngineTests: XCTestCase {

    func observerTest(sequence: AKSequence,
                      frameCount: AUAudioFrameCount = 44100,
                      renderCallCount: Int = 1) -> [AKMIDIEvent] {

        let engine = akSequencerEngineCreate()

        let settings = AKSequenceSettings(maximumPlayCount: 1,
                                          length: 4,
                                          tempo: 120,
                                          loopEnabled: true,
                                          numberOfLoops: 0)

        var events = [AKMIDIEvent]()

        let block: AUScheduleMIDIEventBlock = { (sampleTime, cable, length, midiBytes) in

            var bytes = [MIDIByte]()
            for index in 0 ..< length {
                bytes.append(midiBytes[index])
            }
            events.append(AKMIDIEvent(data: bytes, offset: MIDITimeStamp(sampleTime - AUEventSampleTimeImmediate)))

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

                akSequencerEngineSetPlaying(engine, true)

                for index in 0..<renderCallCount {
                    timeStamp.mSampleTime = Double(Int(frameCount) * index)
                    observer(.unitRenderAction_PreRender, &timeStamp, frameCount, 0 /* outputBusNumber*/)
                }

            }
        }

        // One second at 120bpm is two beats
        XCTAssertEqual(akSequencerEngineGetPosition(engine), fmod(2.0 * Double(Int(frameCount) * renderCallCount) / 44100, 4), accuracy: 0.0001)

        akSequencerEngineDestroy(engine)

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

    func testEmpty() {

        let events = observerTest(sequence: AKSequence())
        XCTAssertEqual(events.count, 0)
    }

    func testChord() {

        var seq = AKSequence()

        seq.add(noteNumber: 60, position: 0.0, duration: 1.0)
        seq.add(noteNumber: 63, position: 0.0, duration: 1.0)
        seq.add(noteNumber: 67, position: 0.0, duration: 1.0)

        let events = observerTest(sequence: seq)
        XCTAssertEqual(events.count, 6)

        XCTAssertEqual(events.map { $0.noteNumber! }, [60, 63, 67, 60, 63, 67])
        XCTAssertEqual(events.map { $0.offset }, [0, 0, 0, 22050, 22050, 22050])
    }

    func testLoop() {
        var seq = AKSequence()

        seq.add(noteNumber: 60, position: 0.0, duration: 0.1)
        seq.add(noteNumber: 63, position: 1.0, duration: 0.1)

        let events = observerTest(sequence: seq, frameCount: 256, renderCallCount: Int(44100 * 10 / 256))
        XCTAssertEqual(events.count, 20)

        XCTAssertEqual(events.map { $0.noteNumber! },
                       [60, 60, 63, 63, 60, 60, 63, 63, 60, 60,
                        63, 63, 60, 60, 63, 63, 60, 60, 63, 63])
        XCTAssertEqual(events.map { $0.offset },[0, 157, 34, 191, 136, 37, 170, 71, 16, 173, 50,
                                                 207, 152, 53, 186, 87, 32, 189, 66, 223])
    }

    func testOverlap() {

        var seq = AKSequence()

        seq.add(noteNumber: 60, position: 0.0, duration: 1.0)
        seq.add(noteNumber: 63, position: 0.1, duration: 0.1)

        let events = observerTest(sequence: seq)
        XCTAssertEqual(events.count, 4)

        XCTAssertEqual(events.map { $0.noteNumber! }, [60, 63, 60, 63])
        XCTAssertEqual(events.map { $0.offset }, [0, 2205, 22050, 4410])
    }

}
