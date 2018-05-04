//
//  AKSequencerTests.swift
//  AudioKitTestSuite
//
//  Created by Jeff Holtzkener on 2018/04/25.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKSequencerTests: AKTestCase {
    var seq: AKSequencer!

    override func setUp() {
        super.setUp()
        seq = AKSequencer()
    }

    // MARK: - Basic AKSequencer behaviour
    func testAKSequencerDefault_newlyCreatedSequencerHasNoTracks() {
        XCTAssertEqual(seq.trackCount, 0)
    }

    func testAKSequencerDefault_newlyCreatedSequencerLengthis0() {
        XCTAssertEqual(seq.length, AKDuration(beats: 0))
    }

    func testNewTrack_addingTrackWillIncreaseTrackCount() {
        let _ = seq.newTrack()

        XCTAssertEqual(seq.trackCount, 1)
    }

    func testNewTrack_addingNewEmptyTrackWillNotAffectLength() {
        let _ = seq.newTrack()

        XCTAssertEqual(seq.length, AKDuration(beats: 0))
    }

    // MARK: - Length
    func testSetLength_settingLengthHasNoEffectIfThereAreNoTracks() {
        seq.setLength(AKDuration(beats: 4.0))

        XCTAssertEqual(seq.length, AKDuration(beats: 0))
    }

    func testSetLength_settingLengthHasEffectsOnSequenceWithEmptyTrack() {
        let _ = seq.newTrack()
        seq.setLength(AKDuration(beats: 4.0))

        XCTAssertEqual(seq.length, AKDuration(beats: 4.0))
    }

    func testSetLength_settingLengthSetsTheLengthOfEachInternalMusicTrack() {
        let _ = seq.newTrack()
        let _ = seq.newTrack()

        seq.setLength(AKDuration(beats: 4.0))

        for track in seq.tracks {
            XCTAssertEqual(track.length, 4.0)
        }
    }

    func testSetLength_shouldTruncateInternalMusicTracks() {
        let originalLength: Double = 8
        let trackA = seq.newTrack()
        trackA?.replaceMIDINoteData(with: generateMIDINoteDataArray(numBeats: Int(originalLength)))

        XCTAssertEqual(trackA!.length, originalLength)
        XCTAssertEqual(trackA!.getMIDINoteData().count, Int(originalLength))

        let newLength: Double = 4.0
        seq.setLength(AKDuration(beats: newLength))

        XCTAssertEqual(trackA!.length, newLength)
        XCTAssertEqual(trackA!.getMIDINoteData().count, Int(newLength))
    }

    func testLength_durationOfLongestTrackDeterminesSequenceLength() {
        let trackA = seq.newTrack()
        trackA?.replaceMIDINoteData(with: generateMIDINoteDataArray(numBeats: 2))

        // longest track is 8 beats
        let trackB = seq.newTrack()
        trackB?.replaceMIDINoteData(with: generateMIDINoteDataArray(numBeats: 8))

        let trackC = seq.newTrack()
        trackC?.replaceMIDINoteData(with: generateMIDINoteDataArray(numBeats: 4))

        XCTAssertEqual(seq.length, AKDuration(beats: 8.0))
    }

    func testLength_settingLengthThenAddingShorterTrackDoesNOTAffectLength() {
        let _ = seq.newTrack()
        let originalLength = AKDuration(beats: 4.0)
        seq.setLength(originalLength)

        let trackA = seq.newTrack()
        trackA?.replaceMIDINoteData(with: generateMIDINoteDataArray(numBeats: 2))

        XCTAssertEqual(seq.length, originalLength)
    }

    func testLength_settingLengthThenAddingLongerTrackWillIncreaseLength() {
        let _ = seq.newTrack()
        let originalLength = AKDuration(beats: 4.0)
        seq.setLength(originalLength)

        let trackA = seq.newTrack()
        trackA?.replaceMIDINoteData(with: generateMIDINoteDataArray(numBeats: 8))

        XCTAssertEqual(seq.length, AKDuration(beats: 8))
    }

    // MARK: - Delete Tracks
    func testDeleteTrack_shouldReduceTrackCount() {
        let _ = seq.newTrack()
        let _ = seq.newTrack()

        XCTAssertEqual(seq.trackCount, 2)

        seq.deleteTrack(trackIndex: 0)

        XCTAssertEqual(seq.trackCount, 1)
    }

    func testDeleteTrack_attemptingToDeleteBadIndexWillHaveNoEffect() {
        // default seq has no tracks
        seq.deleteTrack(trackIndex: 3)

        // no effect, i.e., it doesn't crash
        XCTAssertEqual(seq.trackCount, 0)
    }

    func testDeleteTrack_deletingLongerTrackWillChangeSequencerLength() {
        let trackA = seq.newTrack()
        trackA?.replaceMIDINoteData(with: generateMIDINoteDataArray(numBeats: 8))

        let trackB = seq.newTrack()
        trackB?.replaceMIDINoteData(with: generateMIDINoteDataArray(numBeats: 4))

        XCTAssertEqual(seq.length, AKDuration(beats: 8.0))

        seq.deleteTrack(trackIndex: 0)

        XCTAssertEqual(seq.length, AKDuration(beats: 4.0))
    }

    func testDeleteTrack_indexOfTracksWithHigherIndicesWillDecrement() {
        let _ = seq.newTrack()
        let _ = seq.newTrack()
        seq.tracks[1].replaceMIDINoteData(with: generateMIDINoteDataArray(numBeats: 4, noteNumber: 72))
        let originalTrack1Data = seq.tracks[1].getMIDINoteData()

        seq.deleteTrack(trackIndex: 0)

        // track 1 decrements to track 0
        XCTAssertEqual(seq.tracks[0].getMIDINoteData(), originalTrack1Data)
    }

    // MARK: - LoadMIDIFile
    func testLoadMIDIFile_seqWillHaveSameNumberOfTracksAsMIDIFile() {
        let numTracks = 4
        let sourceSeq = generatePopulatedSequencer(numBeats: 8, numTracks: numTracks)
        let midiURL = sourceSeq.writeDataToURL()

        seq.loadMIDIFile(fromURL: midiURL)
        XCTAssertEqual(seq.trackCount, numTracks)
    }

    func testLoadMIDIFile_shouldCompletlyOverwriteExistingContent() {
        // original seq will have three tracks, 8 beats long
        for _ in 0 ..< 3 {
            let newTrack = seq.newTrack()
            newTrack?.replaceMIDINoteData(with: generateMIDINoteDataArray(numBeats: 8))
        }
        XCTAssertEqual(seq.trackCount, 3)
        XCTAssertEqual(seq.length, AKDuration(beats: 8))

        // replacement has one track, 4 beats long
        let replacement = generatePopulatedSequencer(numBeats: 4, numTracks: 1)
        let midiURL = replacement.writeDataToURL()
        seq.loadMIDIFile(fromURL: midiURL)

        XCTAssertEqual(seq.trackCount, 1)
        XCTAssertEqual(seq.length, AKDuration(beats: 4))
    }

    func testLoadMIDIFile_shouldCopyTracksWithoutMIDINoteEvents() {
        let numTracks = 4
        let sourceSeq = generatePopulatedSequencer(numBeats: 8, numTracks: numTracks)
        let _ = sourceSeq.newTrack() // plus one empty track
        let midiURL = sourceSeq.writeDataToURL()

        seq.loadMIDIFile(fromURL: midiURL)
        XCTAssertEqual(seq.trackCount, numTracks + 1)
    }

    func testLoadMIDIFile_shouldCopyTempoEvents() {
        let originalTempo = 90.0
        seq.setTempo(originalTempo)
        seq.setTime(0.1) // to accurately get tempo
        XCTAssertEqual(seq.tempo, originalTempo, accuracy: 0.1)

        let sourceSeqTempo: Double = 180.0
        let sourceSeq = generatePopulatedSequencer(numBeats: 8, numTracks: 2)
        sourceSeq.setTempo(sourceSeqTempo)
        sourceSeq.setTime(0.1)
        XCTAssertEqual(sourceSeq.tempo, sourceSeqTempo, accuracy: 0.1)
        let midiURL = sourceSeq.writeDataToURL()

        seq.loadMIDIFile(fromURL: midiURL)
        XCTAssertEqual(seq.tempo, sourceSeqTempo, accuracy: 0.1)
    }

    // MARK: - AddMIDIFileTracks
    func testAddMIDIFileTracks_shouldNotAffectCurrentTracks() {
        // original sequencer
        let _ = seq.newTrack()
        let _ = seq.newTrack()
        seq.tracks[0].replaceMIDINoteData(with: generateMIDINoteDataArray(numBeats: 8, noteNumber: 30))
        let originalTrack0NoteData = seq.tracks[0].getMIDINoteData()
        seq.tracks[1].replaceMIDINoteData(with: generateMIDINoteDataArray(numBeats: 8, noteNumber: 40))
        let originalTrack1NoteData = seq.tracks[1].getMIDINoteData()

        // add another MIDI File
        let newSeq = generatePopulatedSequencer(numBeats: 8, noteNumber: 60, numTracks: 1)
        let midiURL = newSeq.writeDataToURL()
        seq.addMIDIFileTracks(midiURL)

        XCTAssertEqual(seq.tracks[0].getMIDINoteData(), originalTrack0NoteData)
        XCTAssertEqual(seq.tracks[1].getMIDINoteData(), originalTrack1NoteData)
    }

    func testAddMIDIFileTracks_addsPopulatedMusicTracksToCurrentSequencer() {
        let numberOfOriginalTracks = 3
        for _ in 0 ..< numberOfOriginalTracks {
            let newTrack = seq.newTrack()
            newTrack?.replaceMIDINoteData(with: generateMIDINoteDataArray(numBeats: 6, noteNumber: 50))
        }

        // add 4 track MIDI file
        let numberOfTracksInNewFile = 4
        let newSeq = generatePopulatedSequencer(numBeats: 4, noteNumber: 60, numTracks: numberOfTracksInNewFile)
        let midiURL = newSeq.writeDataToURL()
        seq.addMIDIFileTracks(midiURL)

        XCTAssertEqual(seq.trackCount, numberOfOriginalTracks + numberOfTracksInNewFile)
    }

    func testAddMIDIFileTracks_shouldNotCopyTempoEvents() {
        let firstSequencerTempo: Double = 200
        seq.setTempo(firstSequencerTempo)
        seq.setTime(0.1) // to read tempo
        XCTAssertEqual(seq.tempo, firstSequencerTempo, accuracy: 0.1)

        let secondSequencerTempo: Double = 90
        let newSeq = generatePopulatedSequencer(numBeats: 8, noteNumber: 60, numTracks: 1)
        newSeq.setTempo(secondSequencerTempo)
        newSeq.setTime(0.1)
        // MIDI file tempo is 90
        XCTAssertEqual(newSeq.tempo, secondSequencerTempo, accuracy: 0.1)

        let midiURL = newSeq.writeDataToURL()
        seq.addMIDIFileTracks(midiURL)

        XCTAssertEqual(seq.tempo, firstSequencerTempo, accuracy: 0.1)
    }

    func testAddMIDIFileTracks_tracksWithoutNoteEventsAreNotCopied() {
        let numberOfOriginalTracks = 3
        for _ in 0 ..< numberOfOriginalTracks {
            let newTrack = seq.newTrack()
            newTrack?.replaceMIDINoteData(with: generateMIDINoteDataArray(numBeats: 6, noteNumber: 50))
        }

        // add 4 track MIDI file with content
        let numberOfTracksWithContent = 4
        let newSeq = generatePopulatedSequencer(numBeats: 4,
                                                noteNumber: 60,
                                                numTracks: numberOfTracksWithContent)
        // add 1 track without content
        let _ = newSeq.newTrack()
        XCTAssertEqual(newSeq.trackCount, numberOfTracksWithContent + 1)
        let midiURL = newSeq.writeDataToURL()
        seq.addMIDIFileTracks(midiURL)

        XCTAssertEqual(seq.trackCount, numberOfOriginalTracks + numberOfTracksWithContent)
    }

    func testAddMIDIFileTracks_addsShorterTracksWillNotAffectSequencerLength() {
        let originalLength = 8
        for _ in 0 ..< 2 {
            let newTrack = seq.newTrack()
            newTrack?.replaceMIDINoteData(with: generateMIDINoteDataArray(numBeats: originalLength, noteNumber: 50))
        }

        let newSeq = generatePopulatedSequencer(numBeats: 4, noteNumber: 60, numTracks: 2)
        let midiURL = newSeq.writeDataToURL()
        seq.addMIDIFileTracks(midiURL)

        XCTAssertEqual(seq.length, AKDuration(beats: Double(originalLength)))
    }

    func testAddMIDIFileTracks_useExistingSequencerLength_shouldTruncateNewTracks() {
        let originalLength = 8
        for _ in 0 ..< 2 {
            let newTrack = seq.newTrack()
            newTrack?.replaceMIDINoteData(with: generateMIDINoteDataArray(numBeats: originalLength, noteNumber: 50))
        }

        let longerLength = 16
        let newSeq = generatePopulatedSequencer(numBeats: longerLength, noteNumber: 60, numTracks: 2)
        let midiURL = newSeq.writeDataToURL()
        seq.addMIDIFileTracks(midiURL, useExistingSequencerLength: true) // default

        XCTAssertEqual(seq.length, AKDuration(beats: Double(originalLength)))
        XCTAssertEqual(seq.tracks[2].length, MusicTimeStamp(originalLength)) // truncated
        XCTAssertEqual(seq.tracks[3].length, MusicTimeStamp(originalLength)) // truncated
    }

    func testAddMIDIFileTracks_NOTuseExistingSequencerLength_newTracksCanIncreaseLength() {
        let originalLength = 8
        for _ in 0 ..< 2 {
            let newTrack = seq.newTrack()
            newTrack?.replaceMIDINoteData(with: generateMIDINoteDataArray(numBeats: originalLength, noteNumber: 50))
        }

        let longerLength = 16
        let newSeq = generatePopulatedSequencer(numBeats: longerLength, noteNumber: 60, numTracks: 2)
        let midiURL = newSeq.writeDataToURL()
        // useExistingSequencerLength = false
        seq.addMIDIFileTracks(midiURL, useExistingSequencerLength: false)

        XCTAssertEqual(seq.length, AKDuration(beats: Double(longerLength)))
        XCTAssertEqual(seq.tracks[0].length, MusicTimeStamp(originalLength))
        XCTAssertEqual(seq.tracks[1].length, MusicTimeStamp(originalLength))
        XCTAssertEqual(seq.tracks[2].length, MusicTimeStamp(longerLength))
        XCTAssertEqual(seq.tracks[3].length, MusicTimeStamp(longerLength))
    }

    // MARK: Time Signature
    func testTimeSignature_tracksByDefaultHaveNoTimeSignatureEvents() {
        XCTAssertEqual(seq.countTimeSignatureEvents(), 0)
    }

    func testAddTimeSignatureEvent_shouldAddSingleEvent() {
        seq.addTimeSignatureEvent(timeSignatureTop: 5,
                                  timeSignatureBottom: AKSequencer.TimeSignatureBottomValue.four)
        XCTAssertEqual(seq.countTimeSignatureEvents(), 1)
    }

    func testAddTimeSignatureEvent_addingEventsShouldClearEarlierEvents() {
        seq.addTimeSignatureEvent(timeSignatureTop: 5,
                                  timeSignatureBottom: AKSequencer.TimeSignatureBottomValue.four)
        seq.addTimeSignatureEvent(timeSignatureTop: 7,
                                  timeSignatureBottom: AKSequencer.TimeSignatureBottomValue.sixteen)
        XCTAssertEqual(seq.countTimeSignatureEvents(), 1)
    }

    // MARK: - helper functions
    func generateMIDINoteDataArray(numBeats: Int, noteNumber: Int = 60) -> [AKMIDINoteData] {
        return (0 ..< numBeats).map { AKMIDINoteData(noteNumber: MIDINoteNumber(noteNumber),
                                                     velocity: MIDIVelocity(120),
                                                     channel: MIDIChannel(0),
                                                     duration: AKDuration(beats: Double(1.0)),
                                                     position: AKDuration(beats: Double($0)))
        }
    }

    func generatePopulatedSequencer(numBeats: Int, noteNumber: Int = 60, numTracks: Int) -> AKSequencer {
        let newSeq = AKSequencer()
        for _ in 0 ..< numTracks {
            let newTrack = newSeq.newTrack()
            newTrack?.replaceMIDINoteData(with: generateMIDINoteDataArray(numBeats: numBeats,
                                                                          noteNumber:  noteNumber))
        }
        return newSeq
    }
}

extension AKSequencer {
    func writeDataToURL() -> URL {
        let directory = NSTemporaryDirectory()
        let url = NSURL.fileURL(withPathComponents: [directory, "temp.mid"])
        let data = genData()
        try! data?.write(to: url!)
        return url!
    }

    func countTimeSignatureEvents() -> Int {
        var tempoTrack: MusicTrack?
        if let existingSequence = sequence {
            MusicSequenceGetTempoTrack(existingSequence, &tempoTrack)
        }

        guard let unwrappedTempoTrack = tempoTrack else {
            return 0
        }

        var timeSigCount = 0
        let timeSignatureMetaEventByte: UInt8 = 0x58
        iterateMusicTrack(unwrappedTempoTrack) { _, _, eventType, eventData, _ in
            guard eventType == kMusicEventType_Meta else { return }
            let data = UnsafePointer<MIDIMetaEvent>(eventData?.assumingMemoryBound(to: MIDIMetaEvent.self))
            guard let dataMetaEventType = data?.pointee.metaEventType else { return }
            if dataMetaEventType == timeSignatureMetaEventByte {
                timeSigCount += 1
            }
        }
        return timeSigCount
    }

    func iterateMusicTrack(_ track: MusicTrack, midiEventHandler: (MusicEventIterator, MusicTimeStamp, MusicEventType, UnsafeRawPointer?, UInt32) -> Void) {
        var tempIterator: MusicEventIterator?
        NewMusicEventIterator(track, &tempIterator)
        guard let iterator = tempIterator else {
            AKLog("Unable to create iterator")
            return
        }
        var eventTime = MusicTimeStamp(0)
        var eventType = MusicEventType()
        var eventData: UnsafeRawPointer?
        var eventDataSize: UInt32 = 0
        var hasNextEvent: DarwinBoolean = false

        MusicEventIteratorHasCurrentEvent(iterator, &hasNextEvent)
        while hasNextEvent.boolValue {
            MusicEventIteratorGetEventInfo(iterator, &eventTime, &eventType, &eventData, &eventDataSize)

            midiEventHandler(iterator, eventTime, eventType, eventData, eventDataSize)

            MusicEventIteratorNextEvent(iterator)
            MusicEventIteratorHasCurrentEvent(iterator, &hasNextEvent)
        }
        DisposeMusicEventIterator(iterator)
    }
}
