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

}
