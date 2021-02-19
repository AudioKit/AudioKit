// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import CAudioKit
import Foundation

#if !os(tvOS)

extension SequenceNote: Equatable {
    /// Equality check
    /// - Parameters:
    ///   - lhs: Left hand side
    ///   - rhs: Right hand side
    /// - Returns: True if equal
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.noteOn == rhs.noteOn
            && lhs.noteOff == rhs.noteOff
    }
}

extension SequenceEvent: Equatable {
    /// Equality check
    /// - Parameters:
    ///   - lhs: Left hand side
    ///   - rhs: Right hand side
    /// - Returns: True if equal
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.status == rhs.status
            && lhs.data1 == rhs.data1
            && lhs.data2 == rhs.data2
            && lhs.beat == rhs.beat
    }
}

extension Array where Element == SequenceEvent {
    /// Sort an array of SequenceEvents by earliest beat time (Double)
    /// - Parameters: none
    /// - Returns: [SequenceEvent]
    public func beatTimeOrdered() -> [SequenceEvent] {
        return self.sorted(by: { (event1:SequenceEvent, event2:SequenceEvent) -> Bool in
            let event1Beat = event1.beat
            let event2Beat = event2.beat
            let simultaneous = (event1Beat == event2Beat) && (event1.data1 == event2.data1)
            if(isNoteOn(event1.status) && isNoteOff(event2.status) && simultaneous) {
                return false
            }
            if(isNoteOff(event1.status) && isNoteOn(event2.status) && simultaneous) {
                return true
            }
            return event1Beat < event2Beat
        })
    }

    private func isNoteOn(_ statusByte: UInt8) -> Bool {
        return statusByte & noteOnByte == noteOnByte
    }

    private func isNoteOff(_ statusByte: UInt8) -> Bool {
        return statusByte & noteOffByte == noteOffByte
    }
}

/// A value type for sequences.
public struct NoteEventSequence: Equatable {
    /// Array of sequence notes
    public var notes: [SequenceNote]
    /// Array of sequenc events
    public var events: [SequenceEvent]

    /// Initialize with notes and events
    /// - Parameters:
    ///   - notes: Array of sequence notes
    ///   - events: Array of sequence events
    public init(notes: [SequenceNote] = [], events: [SequenceEvent] = []) {
        self.notes = notes
        self.events = events
    }

    /// Add a note
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number
    ///   - velocity: MIDI Velocity
    ///   - channel: MIDI Channel
    ///   - position: Position or time to start
    ///   - duration: Length of time until note is stopped
    public mutating func add(noteNumber: MIDINoteNumber,
                             velocity: MIDIVelocity = 127,
                             channel: MIDIChannel = 0,
                             position: Double,
                             duration: Double) {
        var newNote = SequenceNote()

        newNote.noteOn.status = noteOnByte
        newNote.noteOn.data1 = noteNumber
        newNote.noteOn.data2 = velocity
        newNote.noteOn.beat = position

        newNote.noteOff.status = noteOffByte
        newNote.noteOff.data1 = noteNumber
        newNote.noteOff.data2 = velocity
        newNote.noteOff.beat = position + duration

        notes.append(newNote)
    }

    /// Remove event that occurs at a specific time
    /// - Parameter position: Time of event
    public mutating func removeEvent(at position: Double) {
        events.removeAll { $0.beat == position }
    }

    /// Remove note that occurs at a specific time
    /// - Parameter position: Time of the note
    public mutating func removeNote(at position: Double) {
        notes.removeAll { $0.noteOn.beat == position }
    }

    /// Remove all occurences of a certain MIDI Note nUmber
    /// - Parameter noteNumber: Note to remove
    public mutating func removeAllInstancesOf(noteNumber: MIDINoteNumber) {
        notes.removeAll { $0.noteOn.data1 == noteNumber }
    }

    /// Add MIDI data to the track as an event
    public mutating func add(status: MIDIStatus, data1: MIDIByte, data2: MIDIByte, position: Double) {
        events.append(SequenceEvent(status: status.byte, data1: data1, data2: data2, beat: position))
    }

    /// Add a MIDI event to the track at a specific position
    public mutating func add(event: MIDIEvent, position: Double) {
        if let status = event.status, event.data.count > 2 {
            add(status: status, data1: event.data[1], data2: event.data[2], position: position)
        }
    }
    /// All MIDI events ordered by earliest beat time
    /// - Returns: Array of SequenceEvents
    public func beatTimeOrderedEvents() -> [SequenceEvent] {
        /// Get all SequenceEvents
        var allEvents: [SequenceEvent] = []
        allEvents.append(contentsOf: events)
        /// Get all SequenceEvents from Notes
        var noteEvents: [SequenceEvent] = []
        notes.forEach { note in
            noteEvents.append(note.noteOn)
            noteEvents.append(note.noteOff)
        }
        allEvents.append(contentsOf: noteEvents)
        return allEvents.beatTimeOrdered()
    }
}

#endif
