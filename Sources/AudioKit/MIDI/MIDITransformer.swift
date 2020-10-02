// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)

import os.log

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
    /// - Parameter transformer: Another MIDI transformer
    /// - Returns: True if equal
    func isEqualTo(_ transformer: MIDITransformer) -> Bool {
        return self == transformer
    }
}

func == (lhs: MIDITransformer, rhs: MIDITransformer) -> Bool {
    return lhs.isEqualTo(rhs)
}

#endif
