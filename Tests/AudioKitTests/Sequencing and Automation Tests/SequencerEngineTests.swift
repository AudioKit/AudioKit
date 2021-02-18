// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit
import CAudioKit
import AVFoundation

class SequencerEngineTests: XCTestCase {

    func observerTest(sequence: NoteEventSequence,
                      frameCount: AUAudioFrameCount = 44100,
                      renderCallCount: Int = 1) -> [MIDIEvent] {

        let engine = akSequencerEngineCreate()

        let settings = SequenceSettings(maximumPlayCount: 1,
                                        length: 4,
                                        tempo: 120,
                                        loopEnabled: true,
                                        numberOfLoops: 0)

        var events = [MIDIEvent]()

        let block: AUScheduleMIDIEventBlock = { (sampleTime, cable, length, midiBytes) in

            var bytes = [MIDIByte]()
            for index in 0 ..< length {
                bytes.append(midiBytes[index])
            }
            events.append(MIDIEvent(data: bytes, offset: MIDITimeStamp(sampleTime - AUEventSampleTimeImmediate)))

        }

        sequence.events.withUnsafeBufferPointer { (eventsPtr: UnsafeBufferPointer<SequenceEvent>) -> Void in
            sequence.notes.withUnsafeBufferPointer { (notesPtr: UnsafeBufferPointer<SequenceNote>) -> Void in
                let observer = SequencerEngineUpdateSequence(engine,
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
        XCTAssertEqual(akSequencerEngineGetPosition(engine),
                       fmod(2.0 * Double(Int(frameCount) * renderCallCount) / 44100, 4),
                       accuracy: 0.0001)

        akSequencerEngineDestroy(engine)

        let sortedEvents = events.sorted { (event1:MIDIEvent, event2:MIDIEvent) -> Bool in
            event1.offset < event2.offset
        }
        return sortedEvents
    }

    func testBasicSequence() {

        var seq = NoteEventSequence()

        seq.add(noteNumber: 60, position: 0.5, duration: 0.1)

        let events = observerTest(sequence: seq)

        XCTAssertEqual(events.count, 2)
        XCTAssertEqual(events[0].noteNumber!, 60)
        XCTAssertEqual(events[0].status!.type, .noteOn)
        XCTAssertEqual(events[0].offset, 11025)
        XCTAssertEqual(events[1].noteNumber!, 60)
        XCTAssertEqual(events[1].status!.type, .noteOff)
        XCTAssertEqual(events[1].offset, 13229)
    }

    func testEmpty() {

        let events = observerTest(sequence: NoteEventSequence())
        XCTAssertEqual(events.count, 0)
    }

    func testChord() {

        var seq = NoteEventSequence()

        seq.add(noteNumber: 60, position: 0.0, duration: 1.0)
        seq.add(noteNumber: 63, position: 0.0, duration: 1.0)
        seq.add(noteNumber: 67, position: 0.0, duration: 1.0)

        let events = observerTest(sequence: seq)
        XCTAssertEqual(events.count, 6)

        XCTAssertEqual(events.map { $0.noteNumber! }, [60, 63, 67, 60, 63, 67])
        XCTAssertEqual(events.map { $0.offset }, [0, 0, 0, 22049, 22049, 22049])
    }

    func testLoop() {
        var seq = NoteEventSequence()

        seq.add(noteNumber: 60, position: 0.0, duration: 0.1)
        seq.add(noteNumber: 63, position: 1.0, duration: 0.1)

        let events = observerTest(sequence: seq, frameCount: 256, renderCallCount: Int(44100 * 10 / 256))
        XCTAssertEqual(events.count, 20)

        XCTAssertEqual(events.map { $0.noteNumber! },
                       [60, 60, 60, 63, 60, 63, 60, 63, 63, 63,
                        60, 60, 60, 63, 60, 63, 60, 63, 63, 63])
        XCTAssertEqual(events.map { $0.offset }, [0, 16, 32, 34, 36, 50, 52,
                                                  66, 70, 86, 136, 152, 156,
                                                  170, 172, 186, 188, 190, 206, 222])
    }

    func testOverlap() {

        var seq = NoteEventSequence()

        seq.add(noteNumber: 60, position: 0.0, duration: 1.0)
        seq.add(noteNumber: 63, position: 0.1, duration: 0.1)

        let events = observerTest(sequence: seq)
        XCTAssertEqual(events.count, 4)

        XCTAssertEqual(events.map { $0.noteNumber! }, [60, 63, 63, 60])
        XCTAssertEqual(events.map { $0.offset }, [0, 2205, 4409, 22049])
    }
    
    func testSameNoteRepeating() {

        var seq = NoteEventSequence()

        seq.add(noteNumber: 60, position: 0.0, duration: 1.0)
        seq.add(noteNumber: 60, position: 1.0, duration: 0.5)

        let events = observerTest(sequence: seq)
        XCTAssertEqual(events.count, 4)

        XCTAssertEqual(events.map { $0.noteNumber! }, [60, 60, 60, 60])
        XCTAssertEqual(events.map { $0.status!.type }, [.noteOn, .noteOff, .noteOn, .noteOff])
        XCTAssertEqual(events.map { $0.offset }, [0, 22049, 22050, 33074])
    }

    func testSameNoteRepeatingInChords() {

        var seq = NoteEventSequence()

        seq.add(noteNumber: 60, position: 0.0, duration: 1.0)
        seq.add(noteNumber: 62, position: 0.0, duration: 1.0)
        seq.add(noteNumber: 64, position: 0.0, duration: 1.0)
        seq.add(noteNumber: 61, position: 1.0, duration: 0.5)
        seq.add(noteNumber: 64, position: 1.0, duration: 0.5)
        seq.add(noteNumber: 62, position: 1.0, duration: 0.5)

        let events = observerTest(sequence: seq)
        XCTAssertEqual(events.count, 12)

        XCTAssertEqual(events.map { $0.noteNumber! }, [60, 62, 64, 60, 62, 64, 61, 64, 62, 61, 64, 62])
        XCTAssertEqual(events.map { $0.status!.type }, [.noteOn, .noteOn, .noteOn, .noteOff, .noteOff,.noteOff,
                                                        .noteOn, .noteOn, .noteOn, .noteOff, .noteOff,.noteOff])
        XCTAssertEqual(events.map { $0.offset }, [0, 0, 0, 22049, 22049, 22049, 22050, 22050, 22050, 33074, 33074, 33074])
    }

    func testSameNoteRepeatingInChordsAcrossLoop() {

        var seq = NoteEventSequence()

        seq.add(noteNumber: 60, position: 0.0, duration: 1.0)
        seq.add(noteNumber: 62, position: 0.0, duration: 1.0)
        seq.add(noteNumber: 64, position: 0.0, duration: 1.0)
        seq.add(noteNumber: 60, position: 1.0, duration: 1.0)
        seq.add(noteNumber: 62, position: 1.0, duration: 1.0)
        seq.add(noteNumber: 64, position: 1.0, duration: 1.0)

        let events = observerTest(sequence: seq, frameCount:512, renderCallCount: 44_100 * 4 / 512)
        XCTAssertEqual(events.count, 24)

        XCTAssertEqual(events.map { $0.noteNumber! }, [60, 62, 64, 60, 62, 64, 60, 62, 64, 60, 62, 64,
                                                       60, 62, 64, 60, 62, 64, 60, 62, 64, 60, 62, 64])
        XCTAssertEqual(events.compactMap { $0.status!.type }, [.noteOn, .noteOn, .noteOn,
                                                        .noteOff, .noteOff,.noteOff,
                                                        .noteOn, .noteOn, .noteOn,
                                                        .noteOff, .noteOff,.noteOff,
                                                        .noteOn, .noteOn, .noteOn,
                                                        .noteOff, .noteOff,.noteOff,
                                                        .noteOn, .noteOn, .noteOn,
                                                        .noteOff, .noteOff,.noteOff])
        XCTAssertEqual(events.map { $0.offset }, [0, 0, 0, 33, 33, 33, 34, 34, 34, 67, 67, 67,
                                                  136, 136, 136, 169, 169, 169, 170, 170, 170, 203, 203, 203])
    }
}
