// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AVFoundation
import XCTest

class AppleSequencerTests: XCTestCase {
    var seq: AppleSequencer!

    override func setUp() {
        super.setUp()
        seq = AppleSequencer()
    }

    // MARK: - Basic AppleSequencer behaviour

    func testAppleSequencerDefault_newlyCreatedSequencerHasNoTracks() {
        XCTAssertEqual(seq.trackCount, 0)
    }

    func testAppleSequencerDefault_newlyCreatedSequencerLengthis0() {
        XCTAssertEqual(seq.length, Duration(beats: 0))
    }

    func testNewTrack_addingTrackWillIncreaseTrackCount() {
        _ = seq.newTrack()

        XCTAssertEqual(seq.trackCount, 1)
    }

    func testNewTrack_addingNewEmptyTrackWillNotAffectLength() {
        _ = seq.newTrack()

        XCTAssertEqual(seq.length, Duration(beats: 0))
    }

    // MARK: - Length

    func testSetLength_settingLengthHasNoEffectIfThereAreNoTracks() {
        seq.setLength(Duration(beats: 4.0))

        XCTAssertEqual(seq.length, Duration(beats: 0))
    }

    func testSetLength_settingLengthHasEffectsOnSequenceWithEmptyTrack() {
        _ = seq.newTrack()
        seq.setLength(Duration(beats: 4.0))

        XCTAssertEqual(seq.length, Duration(beats: 4.0))
    }

    func testSetLength_settingLengthSetsTheLengthOfEachInternalMusicTrack() {
        _ = seq.newTrack()
        _ = seq.newTrack()

        seq.setLength(Duration(beats: 4.0))

        for track in seq.tracks {
            XCTAssertEqual(track.length, 4.0)
        }
    }

    func testSetLength_shouldTruncateInternalMusicTracks() {
        let originalLength: Double = 8
        let trackA = seq.newTrack()
        trackA?.replaceMIDINoteData(with: generateMIDINoteDataArray(beatCount: Int(originalLength)))

        XCTAssertEqual(trackA!.length, originalLength)
        XCTAssertEqual(trackA!.getMIDINoteData().count, Int(originalLength))

        let newLength = 4.0
        seq.setLength(Duration(beats: newLength))

        XCTAssertEqual(trackA!.length, newLength)
        XCTAssertEqual(trackA!.getMIDINoteData().count, Int(newLength))
    }

    func testLength_durationOfLongestTrackDeterminesSequenceLength() {
        let trackA = seq.newTrack()
        trackA?.replaceMIDINoteData(with: generateMIDINoteDataArray(beatCount: 2))

        // longest track is 8 beats
        let trackB = seq.newTrack()
        trackB?.replaceMIDINoteData(with: generateMIDINoteDataArray(beatCount: 8))

        let trackC = seq.newTrack()
        trackC?.replaceMIDINoteData(with: generateMIDINoteDataArray(beatCount: 4))

        XCTAssertEqual(seq.length, Duration(beats: 8.0))
    }

    func testLength_settingLengthThenAddingShorterTrackDoesNOTAffectLength() {
        _ = seq.newTrack()
        let originalLength = Duration(beats: 4.0)
        seq.setLength(originalLength)

        let trackA = seq.newTrack()
        trackA?.replaceMIDINoteData(with: generateMIDINoteDataArray(beatCount: 2))

        XCTAssertEqual(seq.length, originalLength)
    }

    func testLength_settingLengthThenAddingLongerTrackWillIncreaseLength() {
        _ = seq.newTrack()
        let originalLength = Duration(beats: 4.0)
        seq.setLength(originalLength)

        let trackA = seq.newTrack()
        trackA?.replaceMIDINoteData(with: generateMIDINoteDataArray(beatCount: 8))

        XCTAssertEqual(seq.length, Duration(beats: 8))
    }

    func testSetLength_willNotTruncateTempoEventsOutsideOfRange() {
        _ = seq.newTrack()
        seq.addTempoEventAt(tempo: 200, position: Duration(beats: 8.0))

        seq.setLength(Duration(beats: 4.0))
        XCTAssertEqual(seq.allTempoEvents.count, 1)
    }

    func testSetLength_willNotTruncateTimeSignatureEventsOutsideOfRange() {
        _ = seq.newTrack()
        seq.addTimeSignatureEvent(at: 8.0,
                                  timeSignature: TimeSignature(topValue: 7,
                                                               bottomValue: TimeSignature.TimeSignatureBottomValue.eight))

        XCTAssertEqual(seq.allTimeSignatureEvents.count, 1)
        seq.setLength(Duration(beats: 4.0))
        XCTAssertEqual(seq.allTimeSignatureEvents.count, 1)
    }

    // MARK: - Getting and Setting Tempo

    func testAllTempoEvents_noTempoEventsShouldYieldEmptyArray() {
        XCTAssertEqual(seq.allTempoEvents.isEmpty, true)
    }

    func testGetTempoAt_noTempoEventsYieldsDefault120BPMAtAnyPoint() {
        seq.setLength(Duration(beats: 4.0))
        XCTAssertEqual(seq.getTempo(at: 0.0), 120.0)
        XCTAssertEqual(seq.getTempo(at: 4.0), 120.0)
        XCTAssertEqual(seq.getTempo(at: 8.0), 120.0)
        XCTAssertEqual(seq.getTempo(at: 12.0), 120.0)
        XCTAssertEqual(seq.getTempo(at: -4.0), 120.0)
    }

    func testAllTempoEvents_shouldCreateSingleTempoEventAt0() {
        seq.setTempo(200.0)
        XCTAssertEqual(seq.allTempoEvents.count, 1)
        XCTAssertEqual(seq.allTempoEvents[0].0, 0.0) // position
        XCTAssertEqual(seq.allTempoEvents[0].1, 200.0) // bpm
    }

    func testGetTempoAt_shouldReturnCorrectValueAfterSetTempo() {
        seq.setTempo(200.0)
        XCTAssertEqual(seq.getTempo(at: 0.0), 200.0)
        XCTAssertEqual(seq.getTempo(at: seq.currentPosition.beats), 200.0)
    }

    func testSetTempo_shouldClearPreviousTempoEvents() {
        seq.setLength(Duration(beats: 4.0))
        seq.setTempo(100.0)
        seq.setTempo(50.0)
        seq.setTempo(200.0)
        XCTAssertEqual(seq.allTempoEvents.count, 1)
        XCTAssertEqual(seq.allTempoEvents[0].0, 0.0) // position
        XCTAssertEqual(seq.allTempoEvents[0].1, 200.0) // bpm
    }

    func testSetTempo_shouldPreserveTimeSignature() {
        seq.setLength(Duration(beats: 4.0))
        seq.addTimeSignatureEvent(timeSignature: sevenEight)
        XCTAssertEqual(seq.allTimeSignatureEvents.count, 1)
        seq.setTempo(200.0)
        XCTAssertEqual(seq.allTimeSignatureEvents.count, 1)
    }

    func testSetTempoGetTempoAt_returnsLastSetEvent() {
        seq.setTempo(100.0)
        seq.setTempo(50.0)
        seq.setTempo(200.0)
        XCTAssertEqual(seq.getTempo(at: 0.0), 200.0)
    }

    func testAddTempoEventAtAllTempoEvents_addingFourEventsYieldsForEventsInArray() {
        seq.setLength(Duration(beats: 4.0))
        seq.addTempoEventAt(tempo: 100.0, position: Duration(beats: 0.0))
        seq.addTempoEventAt(tempo: 110.0, position: Duration(beats: 1.0))
        seq.addTempoEventAt(tempo: 120.0, position: Duration(beats: 2.0))
        seq.addTempoEventAt(tempo: 130.0, position: Duration(beats: 3.0))

        XCTAssertEqual(seq.allTempoEvents.count, 4)
    }

    func testAddTempoEventAtGetTempoAt_getTempoAtGivesTempoForEventWhenTimeStampIsEqual() {
        seq.setLength(Duration(beats: 4.0))
        seq.addTempoEventAt(tempo: 130.0, position: Duration(beats: 3.0))

        XCTAssertEqual(seq.getTempo(at: 3.0), 130.0)
    }

    func testAddTempoEventAtGetTempoAt_givesTempoForEarlierEventWhenBetweenEvents() {
        seq.setLength(Duration(beats: 4.0))
        seq.addTempoEventAt(tempo: 100.0, position: Duration(beats: 0.0))
        seq.addTempoEventAt(tempo: 130.0, position: Duration(beats: 3.0))

        XCTAssertEqual(seq.getTempo(at: 2.0), 100.0)
    }

    func testSetTempo_shouldClearEventsAddedByAddTempoEventAt() {
        seq.setLength(Duration(beats: 4.0))

        for i in 0 ..< 4 {
            seq.addTempoEventAt(tempo: 100.0, position: Duration(beats: Double(i)))
        }

        seq.setTempo(200.0)
        XCTAssertEqual(seq.allTempoEvents.count, 1)
    }

    func testAddTempoEventAt_shouldLeaveEventAddedBySetTempo() {
        seq.setLength(Duration(beats: 4.0))
        seq.setTempo(100.0)
        seq.addTempoEventAt(tempo: 200.0, position: Duration(beats: 2.0))

        XCTAssertEqual(seq.allTempoEvents.count, 2)
    }

    func testAddTempoEventAt_shouldOverrideButNotDeleteExistingEvent() {
        seq.setLength(Duration(beats: 4.0))
        seq.setTempo(100.0) // sets at 0.0
        seq.addTempoEventAt(tempo: 200.0, position: Duration(beats: 0.0))

        XCTAssertEqual(seq.allTempoEvents.count, 2)
        XCTAssertEqual(seq.getTempo(at: 0.0), 200.0)
    }

    // MARK: - Delete Tracks

    func testDeleteTrack_shouldReduceTrackCount() {
        _ = seq.newTrack()
        _ = seq.newTrack()

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
        trackA?.replaceMIDINoteData(with: generateMIDINoteDataArray(beatCount: 8))

        let trackB = seq.newTrack()
        trackB?.replaceMIDINoteData(with: generateMIDINoteDataArray(beatCount: 4))

        XCTAssertEqual(seq.length, Duration(beats: 8.0))

        seq.deleteTrack(trackIndex: 0)

        XCTAssertEqual(seq.length, Duration(beats: 4.0))
    }

    func testDeleteTrack_indexOfTracksWithHigherIndicesWillDecrement() {
        _ = seq.newTrack()
        _ = seq.newTrack()
        seq.tracks[1].replaceMIDINoteData(with: generateMIDINoteDataArray(beatCount: 4, noteNumber: 72))
        let originalTrack1Data = seq.tracks[1].getMIDINoteData()

        seq.deleteTrack(trackIndex: 0)

        // track 1 decrements to track 0
        XCTAssertEqual(seq.tracks[0].getMIDINoteData(), originalTrack1Data)
    }

    // MARK: - LoadMIDIFile

    func testLoadMIDIFile_seqWillHaveSameNumberOfTracksAsMIDIFile() {
        let trackCount = 4
        let sourceSeq = generatePopulatedSequencer(numBeats: 8, numTracks: trackCount)
        let midiURL = sourceSeq.writeDataToURL()

        seq.loadMIDIFile(fromURL: midiURL)
        XCTAssertEqual(seq.trackCount, trackCount)
    }

    func testLoadMIDIFile_shouldCompletelyOverwriteExistingContent() {
        // original seq will have three tracks, 8 beats long
        for _ in 0 ..< 3 {
            let newTrack = seq.newTrack()
            newTrack?.replaceMIDINoteData(with: generateMIDINoteDataArray(beatCount: 8))
        }
        XCTAssertEqual(seq.trackCount, 3)
        XCTAssertEqual(seq.length, Duration(beats: 8))

        // replacement has one track, 4 beats long
        let replacement = generatePopulatedSequencer(numBeats: 4, numTracks: 1)
        let midiURL = replacement.writeDataToURL()
        seq.loadMIDIFile(fromURL: midiURL)

        XCTAssertEqual(seq.trackCount, 1)
        XCTAssertEqual(seq.length, Duration(beats: 4))
    }

    func testLoadMIDIFile_shouldCopyTracksWithoutMIDINoteEvents() {
        let trackCount = 4
        let sourceSeq = generatePopulatedSequencer(numBeats: 8, numTracks: trackCount)
        _ = sourceSeq.newTrack() // plus one empty track
        let midiURL = sourceSeq.writeDataToURL()

        seq.loadMIDIFile(fromURL: midiURL)
        XCTAssertEqual(seq.trackCount, trackCount + 1)
    }

    func testLoadMIDIFile_shouldCopyTempoEventsRemovingOriginal() {
        let originalTempo = 90.0
        seq.setTempo(originalTempo)
        // original seq has own tempo event
        XCTAssertEqual(seq.getTempo(at: seq.currentPosition.beats), originalTempo, accuracy: 0.1)

        let sourceSeqTempo = 180.0
        let sourceSeq = generatePopulatedSequencer(numBeats: 8, numTracks: 2)
        sourceSeq.setTempo(sourceSeqTempo)
        // copy source also has its own tempo event
        XCTAssertEqual(sourceSeq.getTempo(at: seq.currentPosition.beats), sourceSeqTempo, accuracy: 0.1)
        let midiURL = sourceSeq.writeDataToURL()

        seq.loadMIDIFile(fromURL: midiURL)
        // result has only one tempo event, i.e., from the loaded MIDI file
        XCTAssertEqual(seq.getTempo(at: seq.currentPosition.beats), sourceSeqTempo, accuracy: 0.1)
        XCTAssertEqual(seq.allTempoEvents.count, 1)
    }

    func testLoadMIDIFile_shouldCopyTimeSignatureEventsRemovingOriginal() {
        seq.addTimeSignatureEvent(at: 0.0, timeSignature: fourFour)
        // original seq has one event of 4/4
        XCTAssertEqual(seq.allTimeSignatureEvents.count, 1)
        XCTAssertEqual(seq.getTimeSignature(at: 0.0), fourFour)

        let sourceSeq = generatePopulatedSequencer(numBeats: 8, numTracks: 2)
        sourceSeq.addTimeSignatureEvent(timeSignature: sevenEight)
        // copy source has one event of 7/8
        XCTAssertEqual(sourceSeq.allTimeSignatureEvents.count, 1)
        XCTAssertEqual(sourceSeq.getTimeSignature(at: 0.0), sevenEight)
        let midiURL = sourceSeq.writeDataToURL()

        seq.loadMIDIFile(fromURL: midiURL)
        // result has only one event, from the loaded MIDI file
        XCTAssertEqual(seq.allTimeSignatureEvents.count, 1)
        XCTAssertEqual(seq.getTimeSignature(at: 0.0), sevenEight)
    }

    // MARK: - AddMIDIFileTracks

    func testAddMIDIFileTracks_shouldNotAffectCurrentTracks() {
        // original sequencer
        _ = seq.newTrack()
        _ = seq.newTrack()
        seq.tracks[0].replaceMIDINoteData(with: generateMIDINoteDataArray(beatCount: 8, noteNumber: 30))
        let originalTrack0NoteData = seq.tracks[0].getMIDINoteData()
        seq.tracks[1].replaceMIDINoteData(with: generateMIDINoteDataArray(beatCount: 8, noteNumber: 40))
        let originalTrack1NoteData = seq.tracks[1].getMIDINoteData()

        // add another MIDI File
        let newSeq = generatePopulatedSequencer(numBeats: 8, noteNumber: 60, numTracks: 1)
        let midiURL = newSeq.writeDataToURL()
        seq.addMIDIFileTracks(midiURL)

        // original track data is unchanged
        XCTAssertEqual(seq.tracks[0].getMIDINoteData(), originalTrack0NoteData)
        XCTAssertEqual(seq.tracks[1].getMIDINoteData(), originalTrack1NoteData)
    }

    func testAddMIDIFileTracks_addsPopulatedMusicTracksToCurrentSequencer() {
        let originalTrackCount = 3
        for _ in 0 ..< originalTrackCount {
            let newTrack = seq.newTrack()
            newTrack?.replaceMIDINoteData(with: generateMIDINoteDataArray(beatCount: 6, noteNumber: 50))
        }

        // add 4 track MIDI file
        let newFileTrackCount = 4
        let newSeq = generatePopulatedSequencer(numBeats: 4, noteNumber: 60, numTracks: newFileTrackCount)
        let midiURL = newSeq.writeDataToURL()
        seq.addMIDIFileTracks(midiURL)

        XCTAssertEqual(seq.trackCount, originalTrackCount + newFileTrackCount)
    }

    func testAddMIDIFileTracks_shouldNotCopyTempoEvents() {
        let firstSequencerTempo: Double = 200
        seq.setTempo(firstSequencerTempo)
        XCTAssertEqual(seq.getTempo(at: seq.currentPosition.beats), firstSequencerTempo, accuracy: 0.1)

        let secondSequencerTempo: Double = 90
        let newSeq = generatePopulatedSequencer(numBeats: 8, noteNumber: 60, numTracks: 1)
        newSeq.setTempo(secondSequencerTempo)
        // MIDI file tempo is 90
        XCTAssertEqual(newSeq.getTempo(at: seq.currentPosition.beats), secondSequencerTempo, accuracy: 0.1)

        let midiURL = newSeq.writeDataToURL()
        seq.addMIDIFileTracks(midiURL)

        // tempo has not been changed by added tracks
        XCTAssertEqual(seq.getTempo(at: seq.currentPosition.beats), firstSequencerTempo, accuracy: 0.1)
    }

    func testAddMIDIFileTracks_shouldNotCopyTimeSigEvents() {
        seq.addTimeSignatureEvent(timeSignature: sevenEight)
        XCTAssertEqual(seq.getTimeSignature(at: 0.0), sevenEight)

        let newSeq = generatePopulatedSequencer(numBeats: 8, noteNumber: 60, numTracks: 1)
        newSeq.addTimeSignatureEvent(timeSignature: fourFour)
        XCTAssertEqual(newSeq.getTimeSignature(at: 0.0), fourFour)

        let midiURL = newSeq.writeDataToURL()
        seq.addMIDIFileTracks(midiURL)

        // Time sig unchanged by time dig in added tracks
        XCTAssertEqual(seq.getTimeSignature(at: 0.0), sevenEight)
        XCTAssertEqual(seq.allTimeSignatureEvents.count, 1)
    }

    func testAddMIDIFileTracks_tracksWithoutNoteEventsAreNotCopied() {
        let originalTrackCount = 3
        for _ in 0 ..< originalTrackCount {
            let newTrack = seq.newTrack()
            newTrack?.replaceMIDINoteData(with: generateMIDINoteDataArray(beatCount: 6, noteNumber: 50))
        }

        // add 4 track MIDI file with content
        let filledTrackCount = 4
        let newSeq = generatePopulatedSequencer(numBeats: 4,
                                                noteNumber: 60,
                                                numTracks: filledTrackCount)
        // add 1 track without content
        _ = newSeq.newTrack()
        XCTAssertEqual(newSeq.trackCount, filledTrackCount + 1)
        let midiURL = newSeq.writeDataToURL()
        seq.addMIDIFileTracks(midiURL)

        // track without content was not copied
        XCTAssertEqual(seq.trackCount, originalTrackCount + filledTrackCount)
    }

    func testAddMIDIFileTracks_addingShorterTracksWillNotAffectSequencerLength() {
        let originalLength = 8
        for _ in 0 ..< 2 {
            let newTrack = seq.newTrack()
            newTrack?.replaceMIDINoteData(with: generateMIDINoteDataArray(beatCount: originalLength, noteNumber: 50))
        }

        let newSeq = generatePopulatedSequencer(numBeats: 4, noteNumber: 60, numTracks: 2)
        let midiURL = newSeq.writeDataToURL()
        seq.addMIDIFileTracks(midiURL)

        // sequence has not become shorter
        XCTAssertEqual(seq.length, Duration(beats: Double(originalLength)))
    }

    func testAddMIDIFileTracks_useExistingSequencerLength_shouldTruncateNewTracks() {
        let originalLength = 8
        for _ in 0 ..< 2 {
            let newTrack = seq.newTrack()
            newTrack?.replaceMIDINoteData(with: generateMIDINoteDataArray(beatCount: originalLength, noteNumber: 50))
        }

        let longerLength = 16
        let newSeq = generatePopulatedSequencer(numBeats: longerLength, noteNumber: 60, numTracks: 2)
        let midiURL = newSeq.writeDataToURL()
        seq.addMIDIFileTracks(midiURL, useExistingSequencerLength: true) // default

        XCTAssertEqual(seq.length, Duration(beats: Double(originalLength)))
        XCTAssertEqual(seq.tracks[2].length, MusicTimeStamp(originalLength)) // truncated
        XCTAssertEqual(seq.tracks[3].length, MusicTimeStamp(originalLength)) // truncated
    }

    func testAddMIDIFileTracks_NOTuseExistingSequencerLength_newTracksCanIncreaseLength() {
        let originalLength = 8
        for _ in 0 ..< 2 {
            let newTrack = seq.newTrack()
            newTrack?.replaceMIDINoteData(with: generateMIDINoteDataArray(beatCount: originalLength, noteNumber: 50))
        }

        let longerLength = 16
        let newSeq = generatePopulatedSequencer(numBeats: longerLength, noteNumber: 60, numTracks: 2)
        let midiURL = newSeq.writeDataToURL()
        // useExistingSequencerLength = false
        seq.addMIDIFileTracks(midiURL, useExistingSequencerLength: false)

        // adding longer tracks has increased seq's length
        XCTAssertEqual(seq.length, Duration(beats: Double(longerLength)))
        XCTAssertEqual(seq.tracks[0].length, MusicTimeStamp(originalLength))
        XCTAssertEqual(seq.tracks[1].length, MusicTimeStamp(originalLength))
        XCTAssertEqual(seq.tracks[2].length, MusicTimeStamp(longerLength))
        XCTAssertEqual(seq.tracks[3].length, MusicTimeStamp(longerLength))
    }

    // MARK: - Time Signature

    func testTimeSignature_tracksByDefaultHaveNoTimeSignatureEvents() {
        XCTAssertEqual(seq.allTimeSignatureEvents.count, 0)
    }

    func testAddTimeSignatureEvent_shouldAddSingleEvent() {
        seq.addTimeSignatureEvent(timeSignature: sevenEight)

        XCTAssertEqual(seq.allTimeSignatureEvents.count, 1)
    }

    func testAddTimeSignatureEvent_addingEventsWithClearFlagOnShouldClearEarlierEvents() {
        seq.addTimeSignatureEvent(timeSignature: sevenEight)
        seq.addTimeSignatureEvent(timeSignature: fourFour)

        XCTAssertEqual(seq.allTimeSignatureEvents.count, 1)
    }

    func testAddTimeSignatureEvent_addingTwoEventsWithClearFlagOffShouldYieldTwoEvents() {
        seq.addTimeSignatureEvent(at: 0.0,
                                  timeSignature: sevenEight,
                                  clearExistingEvents: false)
        seq.addTimeSignatureEvent(at: 2.0,
                                  timeSignature: fourFour,
                                  clearExistingEvents: false)

        XCTAssertEqual(seq.allTimeSignatureEvents.count, 2)
    }

    func testAddTimeSignatureEvent_shouldAddCorrectTimeSignature() {
        seq.addTimeSignatureEvent(timeSignature: sevenEight)
        let timeSig = seq.allTimeSignatureEvents[0]

        XCTAssertEqual(timeSig.0, 0.0)
        XCTAssertEqual(timeSig.1, sevenEight)
    }

    func testAddTimeSignatureEvent_canAddEventToNonZeroPositions() {
        seq.addTimeSignatureEvent(at: 1.0, timeSignature: sevenEight)
        let timeSig = seq.allTimeSignatureEvents[0]
        XCTAssertEqual(timeSig.0, 1.0)
        XCTAssertEqual(timeSig.1, sevenEight)
    }

    func testAddTimeSignatureEvent_willAddMultipleEventsToSamePosition() {
        for _ in 0 ..< 4 {
            seq.addTimeSignatureEvent(at: 0.0,
                                      timeSignature: sevenEight,
                                      clearExistingEvents: false)
        }

        XCTAssertEqual(seq.allTimeSignatureEvents.count, 4)
        for event in seq.allTimeSignatureEvents {
            XCTAssertEqual(event.0, 0.0)
        }
    }

    func testGetTimeSignatureAt_noEventsWillYieldFourFour() {
        XCTAssertEqual(seq.allTimeSignatureEvents.count, 0)
        XCTAssertEqual(seq.getTimeSignature(at: 0.0), fourFour)
    }

    func testGetTimeSignatureAt_eventAtStartWillGiveCorrectTSAtAllPositions() {
        seq.addTimeSignatureEvent(at: 0.0, timeSignature: sevenEight)

        XCTAssertEqual(seq.getTimeSignature(at: 0.0), sevenEight)
        XCTAssertEqual(seq.getTimeSignature(at: 3.0), sevenEight)
    }

    func testGetTimeSignatureAt_eventAtLaterPositionWillGiveFourFourBeforeEvent() {
        seq.addTimeSignatureEvent(at: 1.0, timeSignature: sevenEight)

        XCTAssertEqual(seq.getTimeSignature(at: 0.0), fourFour)
        XCTAssertEqual(seq.getTimeSignature(at: 1.0), sevenEight)
    }

    func testGetTimeSignatureAt_willGiveCorrectResultForMultipleEventsAtExactPosition() {
        seq.setLength(Duration(beats: 4))
        seq.addTimeSignatureEvent(at: 0.0, timeSignature: sevenEight, clearExistingEvents: false)
        seq.addTimeSignatureEvent(at: 1.0, timeSignature: fourFour, clearExistingEvents: false)
        seq.addTimeSignatureEvent(at: 2.0, timeSignature: sevenEight, clearExistingEvents: false)
        seq.addTimeSignatureEvent(at: 3.0, timeSignature: fourFour, clearExistingEvents: false)

        XCTAssertEqual(seq.getTimeSignature(at: 0.0), sevenEight)
        XCTAssertEqual(seq.getTimeSignature(at: 1.0), fourFour)
        XCTAssertEqual(seq.getTimeSignature(at: 2.0), sevenEight)
        XCTAssertEqual(seq.getTimeSignature(at: 3.0), fourFour)
    }

    func testGetTimeSignatureAt_willGiveCorrectResultForMultipleEventsBetweenPositions() {
        seq.setLength(Duration(beats: 4))
        seq.addTimeSignatureEvent(at: 0.0, timeSignature: sevenEight, clearExistingEvents: false)
        seq.addTimeSignatureEvent(at: 1.0, timeSignature: fourFour, clearExistingEvents: false)
        seq.addTimeSignatureEvent(at: 2.0, timeSignature: sevenEight, clearExistingEvents: false)
        seq.addTimeSignatureEvent(at: 3.0, timeSignature: fourFour, clearExistingEvents: false)

        XCTAssertEqual(seq.getTimeSignature(at: 0.5), sevenEight)
        XCTAssertEqual(seq.getTimeSignature(at: 1.5), fourFour)
        XCTAssertEqual(seq.getTimeSignature(at: 2.5), sevenEight)
        XCTAssertEqual(seq.getTimeSignature(at: 3.5), fourFour)
    }

    // MARK: - Time Conversion

    func testHostTimeForBeats_shouldReportErrorWhenNotPlaying() {
        XCTAssertThrowsError(try seq.hostTime(forBeats: 0))
    }

    func testHostTimeForBeats_willGiveCorrectResultForConstantTempo() throws {
        let newTrack = try XCTUnwrap(seq.newTrack())
        newTrack.replaceMIDINoteData(with: generateMIDINoteDataArray(beatCount: 4, noteNumber: 50))
        seq.setTempo(90)
        seq.play()
        let estimatedPlayerStartTime = mach_absolute_time()
        let beatTime = try seq.hostTime(forBeats: 4)
        seq.stop()
        let expected4thBeatHostTime = UInt64(
            Double(4 * 60.0 / 90.0) * Double(NSEC_PER_SEC) *
                Double(machTimebaseInfo.denom) / Double(machTimebaseInfo.numer)
        ) + estimatedPlayerStartTime
        let diff = abs(CMClockMakeHostTimeFromSystemUnits(beatTime).seconds -
            CMClockMakeHostTimeFromSystemUnits(expected4thBeatHostTime).seconds)
        XCTAssert(diff < 0.1)
    }

    func testHostTimeForBeats_willGiveCorrectResultForMultipleTempoEvents() throws {
        let newTrack = try XCTUnwrap(seq.newTrack())
        newTrack.replaceMIDINoteData(with: generateMIDINoteDataArray(beatCount: 4, noteNumber: 50))
        seq.setTempo(90)
        seq.addTempoEventAt(tempo: 60, position: Duration(beats: 2))
        seq.play()
        let estimatedPlayerStartTime = mach_absolute_time()
        let beatTime = try seq.hostTime(forBeats: 4)
        seq.stop()
        let beatTimeInSeconds: TimeInterval = 2.0 * 60.0 / 90.0 + 2.0 * 60.0 / 60.0
        let expected4thBeatHostTime = UInt64(
            beatTimeInSeconds * Double(NSEC_PER_SEC) *
                Double(machTimebaseInfo.denom) / Double(machTimebaseInfo.numer)
        ) + estimatedPlayerStartTime
        let diff = abs(CMClockMakeHostTimeFromSystemUnits(beatTime).seconds -
            CMClockMakeHostTimeFromSystemUnits(expected4thBeatHostTime).seconds)
        XCTAssert(diff < 0.1)
    }

    func testBeatsForHostTime_shouldReportErrorWhenNotPlaying() {
        XCTAssertThrowsError(try seq.beats(forHostTime: mach_absolute_time()))
    }

    func testBeatsForHostTime_willGiveCorrectResultForConstantTempo() throws {
        let newTrack = try XCTUnwrap(seq.newTrack())
        newTrack.replaceMIDINoteData(with: generateMIDINoteDataArray(beatCount: 4, noteNumber: 50))
        seq.setTempo(90)
        seq.play()
        let estimatedPlayerStartTime = mach_absolute_time()
        let expected4thBeatTime = UInt64(
            Double(4 * 60.0 / 90.0) * Double(NSEC_PER_SEC) *
                Double(machTimebaseInfo.denom) / Double(machTimebaseInfo.numer)
        ) + estimatedPlayerStartTime
        let beat = try seq.beats(forHostTime: expected4thBeatTime)
        seq.stop()
        XCTAssert(round(beat) == 4)
    }

    func testBeatsForHostTime_willGiveCorrectResultForMultipleTempoEvents() throws {
        let newTrack = try XCTUnwrap(seq.newTrack())
        newTrack.replaceMIDINoteData(with: generateMIDINoteDataArray(beatCount: 4, noteNumber: 50))
        seq.setTempo(90)
        seq.addTempoEventAt(tempo: 60, position: Duration(beats: 2))
        seq.play()
        let estimatedPlayerStartTime = mach_absolute_time()
        let beatTimeInSeconds: TimeInterval = 2.0 * 60.0 / 90.0 + 2.0 * 60.0 / 60.0
        let expected4thBeatHostTime = UInt64(
            beatTimeInSeconds * Double(NSEC_PER_SEC) *
                Double(machTimebaseInfo.denom) / Double(machTimebaseInfo.numer)
        ) + estimatedPlayerStartTime
        let beat = try seq.beats(forHostTime: expected4thBeatHostTime)
        seq.stop()
        XCTAssert(round(beat) == 4)
    }

    #if os(macOS) // For some reason failing on iOS and tvOS
    func testChords() {
        let url = Bundle.module.url(forResource: "chords", withExtension: "mid", subdirectory: "TestResources")!
        seq.loadMIDIFile(fromURL: url)

        var eventCount = 0
        let expectedEvents = 24
        let expect = XCTestExpectation(description: "wait for callback")

        let inst = MIDICallbackInstrument(midiInputName: "test") { byte0, byte1, byte2 in
            print("received midi \(byte0), \(byte1), \(byte2)")
            eventCount += 1
            if eventCount == expectedEvents {
                expect.fulfill()
            }
        }

        seq.setGlobalMIDIOutput(inst.midiIn)
        seq.play()

        wait(for: [expect], timeout: 5.0)

        XCTAssertEqual(eventCount, expectedEvents)
    }
    #endif

    // MARK: - helper functions

    func generateMIDINoteDataArray(beatCount: Int, noteNumber: Int = 60) -> [MIDINoteData] {
        return (0 ..< beatCount).map { MIDINoteData(noteNumber: MIDINoteNumber(noteNumber),
                                                    velocity: MIDIVelocity(120),
                                                    channel: MIDIChannel(0),
                                                    duration: Duration(beats: Double(1.0)),
                                                    position: Duration(beats: Double($0)))
        }
    }

    func generatePopulatedSequencer(numBeats: Int, noteNumber: Int = 60, numTracks: Int) -> AppleSequencer {
        let newSeq = AppleSequencer()
        for _ in 0 ..< numTracks {
            let newTrack = newSeq.newTrack()
            newTrack?.replaceMIDINoteData(with: generateMIDINoteDataArray(beatCount: numBeats,
                                                                          noteNumber: noteNumber))
        }
        return newSeq
    }

    let fourFour = TimeSignature(topValue: 4,
                                 bottomValue: TimeSignature.TimeSignatureBottomValue.four)
    let sevenEight = TimeSignature(topValue: 7,
                                   bottomValue: TimeSignature.TimeSignatureBottomValue.eight)

    let machTimebaseInfo: mach_timebase_info = {
        var info = mach_timebase_info()
        let machTimebaseInfoResult = mach_timebase_info(&info)
        precondition(machTimebaseInfoResult == KERN_SUCCESS)
        return info
    }()
}

extension AppleSequencer {
    func writeDataToURL() -> URL {
        let directory = NSTemporaryDirectory()
        let url = NSURL.fileURL(withPathComponents: [directory, "temp.mid"])
        let data = genData()
        try! data?.write(to: url!)
        return url!
    }

    func iterateMusicTrack(_ track: MusicTrack, midiEventHandler: (MusicEventIterator, MusicTimeStamp, MusicEventType, UnsafeRawPointer?, UInt32, inout Bool) -> Void) {
        var tempIterator: MusicEventIterator?
        NewMusicEventIterator(track, &tempIterator)
        guard let iterator = tempIterator else {
            Log("Unable to create iterator")
            return
        }
        var eventTime = MusicTimeStamp(0)
        var eventType = MusicEventType()
        var eventData: UnsafeRawPointer?
        var eventDataSize: UInt32 = 0
        var hasNextEvent: DarwinBoolean = false
        var isReadyForNextEvent = true

        MusicEventIteratorHasCurrentEvent(iterator, &hasNextEvent)
        while hasNextEvent.boolValue {
            MusicEventIteratorGetEventInfo(iterator, &eventTime, &eventType, &eventData, &eventDataSize)

            midiEventHandler(iterator, eventTime, eventType, eventData, eventDataSize, &isReadyForNextEvent)

            MusicEventIteratorNextEvent(iterator)
            MusicEventIteratorHasCurrentEvent(iterator, &hasNextEvent)
        }
        DisposeMusicEventIterator(iterator)
    }
}
