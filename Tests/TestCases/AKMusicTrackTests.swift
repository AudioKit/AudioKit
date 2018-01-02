//
//  AKMusicTrackTests.swift
//  AudioKitTestSuite
//
//  Created by Derek Lee, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKMusicTrackTests: AKTestCase {
    var musicTrack: AKMusicTrack!

    override func setUp() {
        super.setUp()

        musicTrack = AKMusicTrack()
        musicTrack.setLength(AKDuration(beats: 4.0))
    }

    // MARK: - add()
    func testAdd_addsANewNote() {
        musicTrack.addNote(withNumber: 60, atPosition: 0.75)


        XCTAssertEqual(musicTrack.noteCount, 1)
        XCTAssertTrue(musicTrack.hasNote(atPosition: 0.75, withNoteNumber: 60))
    }

    // MARK: - clear()
    func testClear_clearsAllNotes() {
        musicTrack.addNote(withNumber: 60, atPosition: 1.0)
        musicTrack.addNote(withNumber: 61, atPosition: 2.0)
        XCTAssertEqual(musicTrack.noteCount, 2)


        musicTrack.clear()


        XCTAssertEqual(musicTrack.noteCount, 0)
    }

    // MARK: - clearRange()
    func testClearRange_doesNotRemoveNotesPriorToTheStartTime() {
        musicTrack.addNote(withNumber: 60, atPosition: 1.99)
        musicTrack.addNote(withNumber: 61, atPosition: 2.0)


        musicTrack.clearRange(
            start: AKDuration(beats: 2.0),
            duration: AKDuration(beats: 1.0)
        )


        XCTAssertTrue(musicTrack.hasNote(atPosition: 1.99, withNoteNumber: 60))
        XCTAssertTrue(musicTrack.doesNotHaveNote(atPosition: 2.0, withNoteNumber: 61))
    }

    func testClearRange_removesNoteInclusiveOfTheStartTime() {
        musicTrack.addNote(withNumber: 60, atPosition: 2.0)


        musicTrack.clearRange(
            start: AKDuration(beats: 2.0),
            duration: AKDuration(beats: 0.1)
        )


        XCTAssertTrue(musicTrack.doesNotHaveNote(atPosition: 2.0, withNoteNumber: 60))
    }

    func testClearRange_removesNoteAtTheEndOfTheDuration() {
        musicTrack.addNote(withNumber: 60, atPosition: 2.99)


        musicTrack.clearRange(
            start: AKDuration(beats: 2.0),
            duration: AKDuration(beats: 1.0)
        )


        XCTAssertTrue(musicTrack.doesNotHaveNote(atPosition: 2.99, withNoteNumber: 60))
    }

    func testClearRange_doesNotRemoveNotesInclusiveOfTheDesiredDuration() {
        musicTrack.addNote(withNumber: 60, atPosition: 2.0)
        musicTrack.addNote(withNumber: 61, atPosition: 3.0)


        musicTrack.clearRange(
            start: AKDuration(beats: 2.0),
            duration: AKDuration(beats: 1.0)
        )


        XCTAssertTrue(musicTrack.doesNotHaveNote(atPosition: 2.0, withNoteNumber: 60))
        XCTAssertTrue(musicTrack.hasNote(atPosition: 3.0, withNoteNumber: 61))
    }
}

// MARK: - For AKMusicTrack Testing
extension AKMusicTrack {
    var noteCount: Int {
        get {
            var count = 0

            iterateThroughEvents { _, eventType, _ in
                if eventType == kMusicEventType_MIDINoteMessage {
                    count += 1
                }
            }

            return count
        }
    }

    func hasNote(atPosition position: MusicTimeStamp,
                 withNoteNumber noteNumber: MIDINoteNumber) -> Bool {
        var noteFound = false

        iterateThroughEvents { eventTime, eventType, eventData in
            if eventType == kMusicEventType_MIDINoteMessage {
                if let midiNoteMessage = eventData?.load(as: MIDINoteMessage.self) {
                    if (eventTime == position && midiNoteMessage.note == noteNumber) {
                        noteFound = true
                    }
                }
            }
        }

        return noteFound
    }

    func doesNotHaveNote(atPosition position: MusicTimeStamp,
                         withNoteNumber noteNumber: MIDINoteNumber) -> Bool {
        return !hasNote(atPosition: position, withNoteNumber: noteNumber)
    }

    func addNote(withNumber noteNumber: MIDINoteNumber,
                 atPosition position: MusicTimeStamp) {
        self.add(
            noteNumber: noteNumber,
            velocity: 127,
            position: AKDuration(beats: position),
            duration: AKDuration(beats: 1.0)
        )
    }

    private func iterateThroughEvents(_ processMIDIEvent: (_ eventTime: MusicTimeStamp, _ eventType: MusicEventType, _ eventData: UnsafeRawPointer?) -> ()) {
        guard let track = internalMusicTrack else {
            XCTFail("internalMusicTrack does not exist")
            return
        }

        var tempIterator: MusicEventIterator?
        NewMusicEventIterator(track, &tempIterator)
        guard let iterator = tempIterator else {
            XCTFail("Unable to create iterator")
            return
        }

        var hasNextEvent: DarwinBoolean = false
        MusicEventIteratorHasCurrentEvent(iterator, &hasNextEvent)

        while hasNextEvent.boolValue {
            var eventTime = MusicTimeStamp(0)
            var eventType = MusicEventType()
            var eventData: UnsafeRawPointer?
            var eventDataSize: UInt32 = 0

            MusicEventIteratorGetEventInfo(iterator, &eventTime, &eventType, &eventData, &eventDataSize)

            processMIDIEvent(eventTime, eventType, eventData)

            MusicEventIteratorNextEvent(iterator)
            MusicEventIteratorHasCurrentEvent(iterator, &hasNextEvent)
        }

        DisposeMusicEventIterator(iterator)
    }
}
