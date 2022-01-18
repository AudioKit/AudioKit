// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)
/// MIDI Note Duration - helpful for storing length of MIDI notes
public class MIDINoteDuration {
    /// Note Start time
    public var noteStartTime = 0.0
    /// Note End time
    public var noteEndTime = 0.0
    /// Note Duration
    public var noteDuration = 0.0
    /// Note Number
    public var noteNumber = 0
    /// Note Number Map
    public var noteNumberMap = 0
    /// Note Range
    public var noteRange = 0

    /// Initialize with common parameters
    /// - Parameters:
    ///   - noteOnPosition: Note start time
    ///   - noteOffPosition: Note end time
    ///   - noteNumber: Note Number
    public init(noteOnPosition: Double, noteOffPosition: Double, noteNumber: Int) {
        self.noteStartTime = noteOnPosition
        self.noteEndTime = noteOffPosition
        self.noteDuration = noteOffPosition - noteOnPosition
        self.noteNumber = noteNumber
    }
}

/// Get the MIDI events which occur inside a MIDI track in a MIDI file
/// This class should only be initialized once if possible - (many calculations are involved)
public class MIDIFileTrackNoteMap {
    /// MIDI File Track
    public let midiTrack: MIDIFileTrack!
    /// MIDI File
    public let midiFile: MIDIFile!
    /// Track number
    public let trackNumber: Int!
    /// Low Note
    public var loNote: Int = 0
    /// High note
    public var hiNote: Int = 0
    /// Note Range
    public var noteRange: Int = 0
    /// End of track
    public var endOfTrack: Double = 0.0
    private var notesInProgress: [Int: (Double, Double)] = [:]
    /// A list of all the note events in the MIDI file for tracking purposes
    public var noteList = [MIDINoteDuration]()

    /// Initialize track map
    /// - Parameters:
    ///   - midiFile: MIDI File
    ///   - trackNumber: Track Number
    public init(midiFile: MIDIFile, trackNumber: Int) {
        self.midiFile = midiFile
        if midiFile.tracks.isNotEmpty {
            if trackNumber > (midiFile.tracks.count - 1) {
                let trackNumber = (midiFile.tracks.count - 1)
                self.midiTrack = midiFile.tracks[trackNumber]
                self.trackNumber = trackNumber
            } else if trackNumber < 0 {
                self.midiTrack = midiFile.tracks[0]
                self.trackNumber = 0
            } else {
                self.midiTrack = midiFile.tracks[trackNumber]
                self.trackNumber = trackNumber
            }
        } else {
            Log("No Tracks in the MIDI File")
            self.midiTrack = midiFile.tracks[0]
            self.trackNumber = 0
        }
        self.getNoteList()
        self.getLoNote()
        self.getHiNote()
        self.getNoteRange()
        self.getEndOfTrack()
    }

    private func addNoteOff(event: MIDIEvent) {
        let eventPosition = (event.positionInBeats ?? 1.0) / Double(self.midiFile.ticksPerBeat ?? 1)
        let noteNumber = Int(event.data[1])
        if let prevPosValue = notesInProgress[noteNumber]?.0 {
            notesInProgress[noteNumber] = (prevPosValue, eventPosition)
            var noteTracker: MIDINoteDuration = MIDINoteDuration(
                noteOnPosition: 0.0,
                noteOffPosition: 0.0, noteNumber: 0)
            if let note = notesInProgress[noteNumber] {
                noteTracker = MIDINoteDuration(
                    noteOnPosition:
                        note.0,
                    noteOffPosition:
                        note.1,
                    noteNumber: noteNumber)
            }
            notesInProgress.removeValue(forKey: noteNumber)
            noteList.append(noteTracker)
        }
    }

    private func addNoteOn(event: MIDIEvent) {
        let eventPosition = (event.positionInBeats ?? 1.0) / Double(self.midiFile.ticksPerBeat ?? 1)
        let noteNumber = Int(event.data[1])
        notesInProgress[noteNumber] = (eventPosition, 0.0)
    }

    private func getNoteList() {
        let events = midiTrack.channelEvents
        var velocityEvent: Int?
        for event in events {
            // Usually the third element of a note event is the velocity
            if event.data.count > 2 {
                velocityEvent = Int(event.data[2])
            }
            if event.status?.type == MIDIStatusType.noteOn {
                // A note played with a velocity of zero is the equivalent
                // of a noteOff command
                if velocityEvent == 0 {
                    addNoteOff(event: event)
                } else {
                    addNoteOn(event: event)
                }
            }
            if event.status?.type == MIDIStatusType.noteOff {
                addNoteOff(event: event)
            }
        }
    }

    private func getLoNote() {
        if noteList.count >= 2 {
            self.loNote = (noteList.min(by: { $0.noteNumber < $1.noteNumber })?.noteNumber) ?? 0
        } else {
            self.loNote = 0
        }
    }

    private func getHiNote() {
        if noteList.count >= 2 {
            self.hiNote = (noteList.max(by: { $0.noteNumber < $1.noteNumber })?.noteNumber) ?? 0
        } else {
            self.hiNote = 0
        }
    }

    private func getNoteRange() {
        // Increment by 1 to properly fit the notes in the MIDI UI View
        self.noteRange = (hiNote - loNote) + 1
    }

    private func getEndOfTrack() {
        let midiTrack = midiFile.tracks[trackNumber]
        let endOfTrackEvent = 47
        var eventTime = 0.0
        for event in midiTrack.events {
            // Again, here we make sure the
            // data is in the proper format
            // for a MIDI end of track message before trying to parse it
            if event.data[1] == endOfTrackEvent && event.data.count >= 3 {
                eventTime = (event.positionInBeats ?? 0.0) / Double(self.midiFile.ticksPerBeat ?? 1)
                self.endOfTrack = eventTime
            } else {
                // Some MIDI files may not
                // have this message. Instead, we can
                // grab the position of the last noteOff message
                if self.noteList.isNotEmpty {
                    self.endOfTrack = self.noteList[self.noteList.count - 1].noteEndTime
                }
            }
        }
        self.endOfTrack = 0.0
    }
}
#endif
