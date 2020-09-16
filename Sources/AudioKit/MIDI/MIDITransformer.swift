// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)

import os.log

public protocol AKMIDITransformer {
    func transform(eventList: [AKMIDIEvent]) -> [AKMIDIEvent]
}

/// Default transformer function
public extension AKMIDITransformer {
    func transform(eventList: [AKMIDIEvent]) -> [AKMIDIEvent] {
        AKLog("MIDI Transformer called", log: OSLog.midi)
        return eventList
    }

    func isEqualTo(_ transformer: AKMIDITransformer) -> Bool {
        return self == transformer
    }
}

func == (lhs: AKMIDITransformer, rhs: AKMIDITransformer) -> Bool {
    return lhs.isEqualTo(rhs)
}

#endif
