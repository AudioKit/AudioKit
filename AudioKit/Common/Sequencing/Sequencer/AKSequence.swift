// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

extension AKSequenceNote: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.noteOn == rhs.noteOn
            && lhs.noteOff == rhs.noteOff
    }
}

extension AKSequenceEvent: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.status == rhs.status
            && lhs.data1 == rhs.data1
            && lhs.data2 == rhs.data2
            && lhs.beat == rhs.beat
    }
}

/// A value type for sequences.
public struct AKSequence: Equatable {

    var notes: [AKSequenceNote]
    var events: [AKSequenceEvent]

    static let noteOn: UInt8 = 0x90
    static let noteOff: UInt8 = 0x80

    public mutating func add(noteNumber: MIDINoteNumber,
             velocity: MIDIVelocity = 127,
             channel: MIDIChannel = 0,
             position: Double,
             duration: Double) {

        var newNote = AKSequenceNote();

        newNote.noteOn.status = AKSequence.noteOn
        newNote.noteOn.data1 = noteNumber
        newNote.noteOn.data2 = velocity
        newNote.noteOn.beat = position

        newNote.noteOff.status = AKSequence.noteOff
        newNote.noteOff.data1 = noteNumber
        newNote.noteOff.data2 = velocity
        newNote.noteOff.beat = position + duration

        notes.append(newNote)
    }

    public mutating func removeEvent(at position: Double) {
        events.removeAll { $0.beat == position }
    }

    public mutating func removeNote(at position: Double) {
        notes.removeAll { $0.noteOn.beat == position }
    }

    public mutating func removeAllInstancesOf(noteNumber: MIDINoteNumber) {
        notes.removeAll { $0.noteOn.data1 == noteNumber }
    }

    /// Add MIDI data to the track as an event
    public mutating func add(status: AKMIDIStatus, data1: UInt8, data2: UInt8, position: Double) {
        events.append(AKSequenceEvent(status: status.byte, data1: data1, data2: data2, beat: position))
    }

    /// Add a MIDI event to the track at a specific position
    public mutating func add(event: AKMIDIEvent, position: Double) {
        if let status = event.status, event.data.count > 2 {
            add(status: status, data1: event.data[1], data2: event.data[2], position: position)
        }
    }

}
