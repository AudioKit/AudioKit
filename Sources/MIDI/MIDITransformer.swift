// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import os.log
import Utilities
import MIDIKitIO

/// MIDI Transformer converting an array of MIDI events into another array
public protocol MIDITransformer {
    /// Transform an array of MIDI events into another array
    /// - Parameter eventList: Array of MIDI events
    func transform(eventList: [MIDIEvent]) -> [MIDIEvent]
}

/// Default transformer function
public extension MIDITransformer {
    /// Transform an array of MIDI events into another array
    /// - Parameter eventList: Array of MIDI events
    /// - Returns: New array of MIDI events
    func transform(eventList: [MIDIEvent]) -> [MIDIEvent] {
        Log("MIDI Transformer called", log: OSLog.midi)
        return eventList
    }

    /// Equality check
    /// - Parameter other: Another MIDI transformer
    /// - Returns: True if equal
    func isEqual(to other: MIDITransformer) -> Bool {
        self == other
    }
}

func == (lhs: MIDITransformer, rhs: MIDITransformer) -> Bool {
    lhs.isEqual(to: rhs)
}
