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
}

#endif
