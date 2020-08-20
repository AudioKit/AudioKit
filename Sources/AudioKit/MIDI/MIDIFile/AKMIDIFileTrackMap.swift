// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

//Keep track of the note durations and range for later use in mapping

#if !os(tvOS)

public class AKMIDINoteDuration {
    public var noteBeginningTime = 0.0
    public var noteEndTime = 0.0
    public var noteDuration = 0.0
    public var noteNum = 0
    public var noteNumMap = 0
    public var noteRange = 0
    public init(noteOnPosition: Double, noteOffPosition: Double, noteNum: Int) {
        self.noteBeginningTime = noteOnPosition
        self.noteEndTime = noteOffPosition
        self.noteDuration = noteOffPosition - noteOnPosition
        self.noteNum = noteNum
    }
}
//Get the MIDI events which occur inside a MIDI track in a MIDI file
public class AKMIDIFileTrackNoteMap {
    public let midiTrack: AKMIDIFileTrack!
    public let midiFile: AKMIDIFile!
    public let trackNum: Int!
    public var loNote: Int {
        if noteList.count >= 2 {
            return (noteList.min(by: { $0.noteNum < $1.noteNum })?.noteNum) ?? 0
        } else {
            return 0
        }
    }
    public var hiNote: Int {
        if noteList.count >= 2 {
            return (noteList.max(by: { $0.noteNum < $1.noteNum })?.noteNum) ?? 0
        } else {
            return 0
        }
    }
    public var noteRange: Int {
        //Increment by 1 to properly fit the notes in the MIDI UI View
        return (hiNote - loNote) + 1
    }

    public var endOfTrack: Double {
        let midiTrack = midiFile.tracks[trackNum]
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

    //A list of all the note events in the MIDI file for tracking purposes
    public var noteList: [AKMIDINoteDuration] {

        var finalNoteList = [AKMIDINoteDuration]()
        var eventPosition = 0.0
        var noteNum = 0
        var noteOn = 0
        var noteOff = 0
        var velocityEvent: Int?
        var notesInProgress: [Int: (Double, Double)] = [:]
        for event in midiTrack.channelEvents {
            let data = event.data
            let eventTypeNum = data[0]
            let eventType = event.status?.type?.description ?? "No Event"

            //Usually the third element of a note event is the velocity
            if data.count > 2 {
                velocityEvent = Int(data[2])
            }

            if noteOn == 0 {
                if eventType == "Note On" {
                    noteOn = Int(eventTypeNum)
                }
            }
            if noteOff == 0 {
                if eventType == "Note Off" {
                    noteOff = Int(eventTypeNum)
                }
            }

            if eventTypeNum == noteOn {
                //A note played with a velocity of zero is the equivalent
                //of a noteOff command
                if velocityEvent == 0 {
                    eventPosition = (event.positionInBeats ?? 1.0) / Double(self.midiFile.ticksPerBeat ?? 1)
                    noteNum = Int(data[1])
                    if let prevPosValue = notesInProgress[noteNum]?.0 {
                        notesInProgress[noteNum] = (prevPosValue, eventPosition)
                        var noteTracker: AKMIDINoteDuration = AKMIDINoteDuration(
                            noteOnPosition: 0.0,
                            noteOffPosition: 0.0, noteNum: 0)
                        if let note = notesInProgress[noteNum] {
                            noteTracker = AKMIDINoteDuration(
                                noteOnPosition:
                                    note.0,
                                noteOffPosition:
                                    note.1,
                                noteNum: noteNum)
                        }
                        notesInProgress.removeValue(forKey: noteNum)
                        finalNoteList.append(noteTracker)
                    }
                } else {
                    eventPosition = (event.positionInBeats ?? 1.0) / Double(self.midiFile.ticksPerBeat ?? 1)
                    noteNum = Int(data[1])
                    notesInProgress[noteNum] = (eventPosition, 0.0)
                }
            }

            if eventTypeNum == noteOff {
                eventPosition = (event.positionInBeats ?? 1.0) / Double(self.midiFile.ticksPerBeat ?? 1)
                noteNum = Int(data[1])
                if let prevPosValue = notesInProgress[noteNum]?.0 {
                    notesInProgress[noteNum] = (prevPosValue, eventPosition)
                    var noteTracker: AKMIDINoteDuration = AKMIDINoteDuration(
                        noteOnPosition: 0.0,
                        noteOffPosition: 0.0, noteNum: 0)
                    if let note = notesInProgress[noteNum] {
                        noteTracker = AKMIDINoteDuration(
                            noteOnPosition:
                                note.0,
                            noteOffPosition:
                                note.1,
                            noteNum: noteNum)
                    }
                    notesInProgress.removeValue(forKey: noteNum)
                    finalNoteList.append(noteTracker)
                }
            }

            eventPosition = 0.0
            noteNum = 0
            velocityEvent = nil
        }
        return finalNoteList
    }

    public init(midiFile: AKMIDIFile, trackNum: Int) {
        self.midiFile = midiFile
        if midiFile.tracks.isNotEmpty {
            if trackNum > (midiFile.tracks.count - 1) {
                let trackNum = (midiFile.tracks.count - 1)
                self.midiTrack = midiFile.tracks[trackNum]
                self.trackNum = trackNum
            } else if trackNum < 0 {
                self.midiTrack = midiFile.tracks[0]
                self.trackNum = 0
            } else {
                self.midiTrack = midiFile.tracks[trackNum]
                self.trackNum = trackNum
            }
        } else {
            AKLog("No Tracks in the MIDI File")
            self.midiTrack = midiFile.tracks[0]
            self.trackNum = 0
        }
    }
}

#endif
