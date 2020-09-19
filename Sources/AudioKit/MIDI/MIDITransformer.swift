// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)

import os.log

public protocol MIDITransformer {
    func transform(eventList: [MIDIEvent]) -> [MIDIEvent]
}

/// Default transformer function
public extension MIDITransformer {
    func transform(eventList: [MIDIEvent]) -> [MIDIEvent] {
        Log("MIDI Transformer called", log: OSLog.midi)
        return eventList
    }

    func isEqualTo(_ transformer: MIDITransformer) -> Bool {
        return self == transformer
    }
}

func == (lhs: MIDITransformer, rhs: MIDITransformer) -> Bool {
    return lhs.isEqualTo(rhs)
}

#endif
