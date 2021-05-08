// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
#if !os(tvOS)

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

        var scheduledEvents = [MIDIEvent]()

        let block: AUScheduleMIDIEventBlock = { (sampleTime, cable, length, midiBytes) in
            var bytes = [MIDIByte]()
            for index in 0 ..< length {
                bytes.append(midiBytes[index])
            }
            let timeStamp = MIDITimeStamp(sampleTime - AUEventSampleTimeImmediate)
            scheduledEvents.append(MIDIEvent(data: bytes, timeStamp: timeStamp))
        }

        let orderedEvents = sequence.beatTimeOrderedEvents()
        orderedEvents.withUnsafeBufferPointer { (eventsPtr: UnsafeBufferPointer<SequenceEvent>) -> Void in
            let observer = akSequencerEngineUpdateSequence(engine,
                                                         eventsPtr.baseAddress,
                                                         orderedEvents.count,
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

        // One second at 120bpm is two beats
        XCTAssertEqual(akSequencerEngineGetPosition(engine),
                       fmod(2.0 * Double(Int(frameCount) * renderCallCount) / 44100, 4),
                       accuracy: 0.0001)

        akSequencerEngineRelease(engine)
        return scheduledEvents
    }

    func testBasicSequence() {

        var seq = NoteEventSequence()

        seq.add(noteNumber: 60, position: 0.5, duration: 0.1)

        let events = observerTest(sequence: seq)

        XCTAssertEqual(events.count, 2)
        XCTAssertEqual(events[0].noteNumber!, 60)
        XCTAssertEqual(events[0].status!.type, .noteOn)
        XCTAssertEqual(events[0].timeStamp, 11025)
        XCTAssertEqual(events[1].noteNumber!, 60)
        XCTAssertEqual(events[1].status!.type, .noteOff)
        XCTAssertEqual(events[1].timeStamp, 13230)
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
        XCTAssertEqual(events.map { $0.timeStamp }, [0, 0, 0, 22050, 22050, 22050])
    }

    func testLoop() {
        var seq = NoteEventSequence()

        seq.add(noteNumber: 60, position: 0.0, duration: 0.1)
        seq.add(noteNumber: 63, position: 1.0, duration: 0.1)

        let events = observerTest(sequence: seq, frameCount: 256, renderCallCount: Int(44100 * 10 / 256))
        XCTAssertEqual(events.count, 20)

        XCTAssertEqual(events.map { $0.noteNumber! },
                       [60, 60, 63, 63, 60, 60, 63, 63, 60, 60, 63, 63, 60, 60, 63, 63, 60, 60, 63, 63])
        XCTAssertEqual(events.map { $0.timeStamp }, [0, 157, 34, 191, 136, 37, 170, 71, 16, 173, 50, 207, 152, 53, 186, 87, 32, 189, 66, 223])
    }

    func testOverlap() {

        var seq = NoteEventSequence()

        seq.add(noteNumber: 60, position: 0.0, duration: 1.0)
        seq.add(noteNumber: 63, position: 0.1, duration: 0.1)

        let events = observerTest(sequence: seq)
        XCTAssertEqual(events.count, 4)

        XCTAssertEqual(events.map { $0.noteNumber! }, [60, 63, 63, 60])
        XCTAssertEqual(events.map { $0.timeStamp }, [0, 2205, 4410, 22050])
    }
    
    func testSameNoteRepeating() {

        var seq = NoteEventSequence()

        seq.add(noteNumber: 60, position: 0.0, duration: 1.0)
        seq.add(noteNumber: 60, position: 1.0, duration: 0.5)

        let events = observerTest(sequence: seq)
        XCTAssertEqual(events.count, 4)

        XCTAssertEqual(events.map { $0.noteNumber! }, [60, 60, 60, 60])
        XCTAssertEqual(events.map { $0.status!.type }, [.noteOn, .noteOff, .noteOn, .noteOff])
        XCTAssertEqual(events.map { $0.timeStamp }, [0, 22050, 22050, 33075])
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
        XCTAssertEqual(events.map { $0.timeStamp }, [0, 0, 0, 22050, 22050, 22050, 22050, 22050, 22050, 33075, 33075, 33075])
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

        XCTAssertEqual(events.map { $0.noteNumber! }, [60, 62, 64, 60, 62, 64,
                                                       60, 62, 64, 60, 62, 64,
                                                       60, 62, 64, 60, 62, 64,
                                                       60, 62, 64, 60, 62, 64])
        XCTAssertEqual(events.compactMap { $0.status!.type }, [.noteOn, .noteOn, .noteOn, .noteOff, .noteOff,.noteOff,
                                                               .noteOn, .noteOn, .noteOn, .noteOff, .noteOff,.noteOff,
                                                               .noteOn, .noteOn, .noteOn, .noteOff, .noteOff,.noteOff,
                                                               .noteOn, .noteOn, .noteOn, .noteOff, .noteOff,.noteOff])
        XCTAssertEqual(events.map { $0.timeStamp }, [0, 0, 0, 34, 34, 34,
                                                  34, 34, 34, 68, 68, 68,
                                                  136, 136, 136, 170, 170, 170,
                                                  170, 170, 170, 204, 204, 204])
    }

    // events that start late in the loop are stopped after the engine is destroyed
    func testShortNotesAcrossLoop() {

        var seq = NoteEventSequence()

        seq.add(noteNumber: 60, position: 0.0, duration: 2.0)
        seq.add(noteNumber: 62, position: 0.0, duration: 2.0)
        seq.add(noteNumber: 65, position: 0.0, duration: 2.0)
        seq.add(noteNumber: 60, position: 3.98, duration: 0.5)
        seq.add(noteNumber: 64, position: 3.98, duration: 0.5)
        seq.add(noteNumber: 67, position: 3.98, duration: 0.5)

        /// 6 render calls at 120bpm, 44100 buffersize is 12 beats, default loop is 4 beats
        let events = observerTest(sequence: seq, renderCallCount: 6)
        XCTAssertEqual(events.count, 30)

        XCTAssertEqual(events.map { $0.noteNumber! }, [60, 62, 65, 60, 62, 65,
                                                       60, 64, 67, 60, 62, 65, 60, 62, 65,
                                                       60, 64, 67, 60, 62, 65, 60, 62, 65,
                                                       60, 64, 67,
                                                       67, 64, 60]) // engine destroyed

        XCTAssertEqual(events.compactMap { $0.status!.type }, [.noteOn, .noteOn, .noteOn, .noteOff, .noteOff, .noteOff,
                                                               .noteOn, .noteOn, .noteOn, .noteOn, .noteOn, .noteOn,
                                                               .noteOff, .noteOff, .noteOff, .noteOn, .noteOn, .noteOn,
                                                               .noteOn, .noteOn, .noteOn, .noteOff, .noteOff, .noteOff,
                                                               .noteOn, .noteOn, .noteOn,
                                                               .noteOff, .noteOff, .noteOff]) // engine destroyed
        XCTAssertEqual(events.map { $0.timeStamp }, [0, 0, 0, 0, 0, 0,
                                                  43658, 43658, 43658, 0, 0, 0,
                                                  0, 0, 0, 43658, 43658, 43658,
                                                  0, 0, 0, 0, 0, 0,
                                                  43658, 43658, 43658,
                                                  1, 1, 1]) // engine destroyed
    }
}
#endif
