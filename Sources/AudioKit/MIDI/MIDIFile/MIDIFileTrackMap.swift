// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

//Keep track of the note durations and range for later use in mapping

#if !os(tvOS)

/// MIDI Note Duration
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
public class MIDIFileTrackNoteMap {
    /// MIDI File Track
    public let midiTrack: MIDIFileTrack!
    /// MIDI File
    public let midiFile: MIDIFile!
    /// Track number
    public let trackNumber: Int!
    /// Low Note
    public var loNote: Int {
        if noteList.count >= 2 {
            return (noteList.min(by: { $0.noteNumber < $1.noteNumber })?.noteNumber) ?? 0
        } else {
            return 0
        }
    }
    /// High note
    public var hiNote: Int {
        if noteList.count >= 2 {
            return (noteList.max(by: { $0.noteNumber < $1.noteNumber })?.noteNumber) ?? 0
        } else {
            return 0
        }
    }
    /// Note Range
    public var noteRange: Int {
        //Increment by 1 to properly fit the notes in the MIDI UI View
        return (hiNote - loNote) + 1
    }

    /// End of track
    public var endOfTrack: Double {
        let midiTrack = midiFile.tracks[trackNumber]
        let endOfTrackEvent = 47
        var eventTime = 0.0
        for event in midiTrack.events {
            //Again, here we make sure the
            //data is in the proper format
            //for a MIDI end of track message before trying to parse it
            if event.data[1] == endOfTrackEvent && event.data.count >= 3 {
                eventTime = (event.positionInBeats ?? 0.0) / Double(self.midiFile.ticksPerBeat ?? 1)
                return eventTime
            } else {
                //Some MIDI files may not
                //have this message. Instead, we can
                //grab the position of the last noteOff message
                if self.noteList.isNotEmpty {
                    return self.noteList[self.noteList.count - 1].noteEndTime
                }
            }
        }
        return 0.0
    }

    /// A list of all the note events in the MIDI file for tracking purposes
    public var noteList: [MIDINoteDuration] {

        var finalNoteList = [MIDINoteDuration]()
        var eventPosition = 0.0
        var noteNumber = 0
        var noteOn = 0
        var noteOff = 0
        var velocityEvent: Int?
        var notesInProgress: [Int: (Double, Double)] = [:]
        for event in midiTrack.channelEvents {
            let data = event.data
            let eventTypeNumber = data[0]
            let eventType = event.status?.type?.description ?? "No Event"

            //Usually the third element of a note event is the velocity
            if data.count > 2 {
                velocityEvent = Int(data[2])
            }

            if noteOn == 0 {
                if eventType == "Note On" {
                    noteOn = Int(eventTypeNumber)
                }
            }
            if noteOff == 0 {
                if eventType == "Note Off" {
                    noteOff = Int(eventTypeNumber)
                }
            }

            if eventTypeNumber == noteOn {
                //A note played with a velocity of zero is the equivalent
                //of a noteOff command
                if velocityEvent == 0 {
                    eventPosition = (event.positionInBeats ?? 1.0) / Double(self.midiFile.ticksPerBeat ?? 1)
                    noteNumber = Int(data[1])
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
                        finalNoteList.append(noteTracker)
                    }
                } else {
                    eventPosition = (event.positionInBeats ?? 1.0) / Double(self.midiFile.ticksPerBeat ?? 1)
                    noteNumber = Int(data[1])
                    notesInProgress[noteNumber] = (eventPosition, 0.0)
                }
            }

            if eventTypeNumber == noteOff {
                eventPosition = (event.positionInBeats ?? 1.0) / Double(self.midiFile.ticksPerBeat ?? 1)
                noteNumber = Int(data[1])
                if let prevPosValue = notesInProgress[noteNumber]?.0 {
                    notesInProgress[noteNumber] = (prevPosValue, eventPosition)
                    var noteTracker: MIDINoteDuration = MIDINoteDuration(
                        noteOnPosition: 0.0,
                        noteOffPosition: 0.0,
                        noteNumber: 0)
                    if let note = notesInProgress[noteNumber] {
                        noteTracker = MIDINoteDuration(
                            noteOnPosition:
                                note.0,
                            noteOffPosition:
                                note.1,
                            noteNumber: noteNumber)
                    }
                    notesInProgress.removeValue(forKey: noteNumber)
                    finalNoteList.append(noteTracker)
                }
            }

            eventPosition = 0.0
            noteNumber = 0
            velocityEvent = nil
        }
        return finalNoteList
    }

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
    }
}

#endif
