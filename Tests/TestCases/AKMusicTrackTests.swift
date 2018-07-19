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

    // MARK: - clearNote()
    func testClearNote_shouldClearAllMatchingNotes() {
        musicTrack.addNote(withNumber: 60, atPosition: 0.0)
        musicTrack.addNote(withNumber: 60, atPosition: 1.0)
        musicTrack.addNote(withNumber: 60, atPosition: 2.0)
        musicTrack.addNote(withNumber: 60, atPosition: 3.0)

        musicTrack.clearNote(60)

        XCTAssertEqual(musicTrack.getMIDINoteData().count, 0)
    }

    func testClearNote_shouldClearOnlyMatchingNotes() {
        musicTrack.addNote(withNumber: 61, atPosition: 0.0)
        musicTrack.addNote(withNumber: 60, atPosition: 1.0)
        musicTrack.addNote(withNumber: 60, atPosition: 2.0)
        musicTrack.addNote(withNumber: 61, atPosition: 3.0)

        musicTrack.clearNote(60)

        XCTAssertEqual(musicTrack.getMIDINoteData().count, 2)
    }

    // MARK: - clearMetaEvent()
    func testClearMetaEvent_clearsAllMetaEvents() {
        let internalTrack = musicTrack.internalMusicTrack!

        var metaEvent = MIDIMetaEvent(metaEventType: 58, unused1: 0, unused2: 0, unused3: 0, dataLength: 0, data: 0)
        for i in 0 ..< 4 {
            MusicTrackNewMetaEvent(internalTrack, MusicTimeStamp(i), &metaEvent)
        }

        XCTAssertEqual(musicTrack.metaEventCount, 5)

        musicTrack.clearMetaEvents()

        XCTAssertEqual(musicTrack.metaEventCount, 0)
    }

    func testClearMetaEvent_clearsOnlyMetaEvents() {
        addSysexMetaEventAndNotes()

        XCTAssertEqual(musicTrack.metaEventCount, 5)
        XCTAssertEqual(musicTrack.sysexEventCount, 4)
        XCTAssertEqual(musicTrack.noteCount, 4)

        musicTrack.clearMetaEvents()

        XCTAssertEqual(musicTrack.metaEventCount, 0)
        XCTAssertEqual(musicTrack.sysexEventCount, 4)
        XCTAssertEqual(musicTrack.noteCount, 4)
    }

    // MARK: - clearSysexEvents
    func testClearSysexEvents_clearsAllSysexEvents() {
        for i in 0 ..< 4 {
            musicTrack.addSysex([0], position: AKDuration(beats: Double(i)))
        }

        XCTAssertEqual(musicTrack.sysexEventCount, 4)

        musicTrack.clearSysexEvents()

        XCTAssertEqual(musicTrack.sysexEventCount, 0)
    }

    func testClearSysexEvents_clearsOnlySysexEvents() {
        addSysexMetaEventAndNotes()

        XCTAssertEqual(musicTrack.metaEventCount, 5)
        XCTAssertEqual(musicTrack.sysexEventCount, 4)

        musicTrack.clearSysexEvents()

        XCTAssertEqual(musicTrack.metaEventCount, 5)
        XCTAssertEqual(musicTrack.sysexEventCount, 0)
        XCTAssertEqual(musicTrack.noteCount, 4)
    }

    // MARK: - clear()
    func testClear_shouldRemoveNotesMetaAndSysex() {
        addSysexMetaEventAndNotes()

        XCTAssertEqual(musicTrack.metaEventCount, 5)
        XCTAssertEqual(musicTrack.sysexEventCount, 4)
        XCTAssertEqual(musicTrack.noteCount, 4)

        musicTrack.clear()

        XCTAssertEqual(musicTrack.metaEventCount, 0)
        XCTAssertEqual(musicTrack.sysexEventCount, 0)
        XCTAssertEqual(musicTrack.noteCount, 0)
    }

    // MARK: - getMIDINoteData
    func testGetMIDINoteData_emptyTrackYieldsEmptyArray() {
        // start with empty track
        XCTAssertEqual(musicTrack.getMIDINoteData().count, 0)
    }

    func testGetMIDINoteData_trackWith4NotesYieldsArrayWIth4Values() {
        addFourNotesToTrack(musicTrack)

        XCTAssertEqual(musicTrack.getMIDINoteData().count, 4)
    }

    func testGetMIDINoteData_notesInSamePositionDoNotOverwrite() {
        musicTrack.add(noteNumber: 60,
                       velocity: 120,
                       position: AKDuration(beats: 0),
                       duration: AKDuration(beats: 0.5))

        musicTrack.add(noteNumber: 72,
                       velocity: 120,
                       position: AKDuration(beats: 0),
                       duration: AKDuration(beats: 0.5))

        XCTAssertEqual(musicTrack.getMIDINoteData().count, 2)
    }

    func testGetMIDINoteData_willNoteCopyMetaEvents() {
        musicTrack.addPitchBend(0, position: AKDuration(beats: 0), channel: 0)

        XCTAssertEqual(musicTrack.getMIDINoteData().count, 0)
    }

    func testGetMIDINoteData_MIDINoteDataElementCorrespondsToNote() {
        let pitch = MIDINoteNumber(60)
        let vel = MIDIVelocity(120)
        let dur = AKDuration(beats: 0.75)
        let channel = MIDIChannel(3)
        let position = AKDuration(beats: 1.5)

        musicTrack.add(noteNumber: pitch,
                       velocity: vel,
                       position: position,
                       duration: dur,
                       channel: channel)

        let noteData = musicTrack.getMIDINoteData()[0]

        XCTAssertEqual(noteData.noteNumber, pitch)
        XCTAssertEqual(noteData.velocity, vel)
        XCTAssertEqual(noteData.duration, dur)
        XCTAssertEqual(noteData.position, position)
        XCTAssertEqual(noteData.channel, channel)
    }

    // MARK: - replaceMIDINoteData
    // helper function
    func addFourNotesToTrack(_ track: AKMusicTrack) {
        for i in 0 ..< 4 {
            track.add(noteNumber: UInt8(60 + i),
                      velocity: 120,
                      position: AKDuration(beats: Double(i)),
                      duration: AKDuration(beats: 0.5))
        }
    }

    func testReplaceMIDINoteData_replacingPopulatedTrackWithEmptyArrayClearsTrack() {
        addFourNotesToTrack(musicTrack)

        musicTrack.replaceMIDINoteData(with: [])

        XCTAssertEqual(musicTrack.getMIDINoteData().count, 0)
    }

    func testReplaceMIDINoteData_canCopyNotesFromOtherTrack() {
        let otherTrack = AKMusicTrack()
        addFourNotesToTrack(otherTrack)

        musicTrack.replaceMIDINoteData(with: otherTrack.getMIDINoteData())

        let musicTrackNoteData = musicTrack.getMIDINoteData()
        let otherTrackNoteData = otherTrack.getMIDINoteData()
        for i in 0 ..< 4 {
            XCTAssertEqual(otherTrackNoteData[i], musicTrackNoteData[i])
        }
    }

    func testReplaceMIDINoteData_orderOfElementsInInputIsIrrelevant() {
        addFourNotesToTrack(musicTrack)
        let originalNoteData = musicTrack.getMIDINoteData()

        musicTrack.replaceMIDINoteData(with: originalNoteData.reversed())
        let newTrackData = musicTrack.getMIDINoteData()

        for i in 0 ..< 4 {
            XCTAssertEqual(newTrackData[i], originalNoteData[i])
        }
    }

    func testReplaceMIDINoteData_canIncreaseLengthOfTrack() {
        addFourNotesToTrack(musicTrack)
        let originalLength = musicTrack.length
        var noteData = musicTrack.getMIDINoteData()

        // increase duration of last note
        noteData[3].duration = AKDuration(beats: 4)
        musicTrack.replaceMIDINoteData(with: noteData)

        XCTAssertTrue(musicTrack.length > originalLength)
    }

    func testReplaceMIDINoteData_willNOTDecreaseLengthOfTrackIfLengthExplicitlyIsSet() {
        // length is explicitly set in setup
        addFourNotesToTrack(musicTrack)
        let originalLength = musicTrack.length
        var noteData = musicTrack.getMIDINoteData()

        // remove last note
        _ = noteData.popLast()
        musicTrack.replaceMIDINoteData(with: noteData)
        XCTAssertEqual(originalLength, musicTrack.length)
    }

    func testReplaceMIDINoteData_willDecreaseLengthOfTrackIfLengthNOTExplicitlySet() {
        // newTrack's length is not explicitly set
        let newTrack = AKMusicTrack()
        addFourNotesToTrack(newTrack)
        let originalLength = newTrack.length
        var noteData = newTrack.getMIDINoteData()

        // remove last note
        _ = noteData.popLast()
        newTrack.replaceMIDINoteData(with: noteData)
        XCTAssertTrue(originalLength > newTrack.length)
    }

    // MARK: - helper functions for reuse
    fileprivate func addSysexMetaEventAndNotes() {
        let internalTrack = musicTrack.internalMusicTrack!

        var metaEvent = MIDIMetaEvent(metaEventType: 58,
                                      unused1: 0,
                                      unused2: 0,
                                      unused3: 0,
                                      dataLength: 0,
                                      data: 0)

        for i in 0 ..< 4 {
            MusicTrackNewMetaEvent(internalTrack, MusicTimeStamp(i), &metaEvent)
            musicTrack.addSysex([0], position: AKDuration(beats: Double(i)))
            musicTrack.addNote(withNumber: 60, atPosition: MusicTimeStamp(i))
        }
    }
}

// MARK: - For AKMusicTrack Testing

extension AKMusicTrack {
    var noteCount: Int {
        var count = 0

        iterateThroughEvents { _, eventType, _ in
            if eventType == kMusicEventType_MIDINoteMessage {
                count += 1
            }
        }

        return count
    }

    var metaEventCount: Int {
        var count = 0

        iterateThroughEvents { _, eventType, _ in
            if eventType == kMusicEventType_Meta {
                count += 1
            }
        }

        return count
    }

    var sysexEventCount: Int {
        var count = 0

        iterateThroughEvents { _, eventType, _ in
            if eventType == kMusicEventType_MIDIRawData {
                count += 1
            }
        }

        return count
    }

    func hasNote(atPosition position: MusicTimeStamp,
                 withNoteNumber noteNumber: MIDINoteNumber) -> Bool {
        var noteFound = false

        iterateThroughEvents { eventTime, eventType, eventData in
            if eventType == kMusicEventType_MIDINoteMessage {
                if let midiNoteMessage = eventData?.load(as: MIDINoteMessage.self) {
                    if eventTime == position && midiNoteMessage.note == noteNumber {
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

    typealias MIDIEventProcessor = (
        _ eventTime: MusicTimeStamp,
        _ eventType: MusicEventType,
        _ eventData: UnsafeRawPointer?
        ) -> Void
    private func iterateThroughEvents(_ processMIDIEvent: MIDIEventProcessor) {
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
