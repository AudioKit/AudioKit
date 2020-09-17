// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)

import CoreMIDI

extension MIDIPacket {
    var isSysEx: Bool {
        return data.0 == MIDISystemCommand.sysEx.rawValue
    }

    var status: MIDIStatus? {
        return MIDIStatus(byte: data.0)
    }

    var channel: MIDIChannel {
        return data.0.lowBit
    }

    var isSystemCommand: Bool {
        return data.0 >= 0xf0
    }

    var systemCommand: MIDISystemCommand? {
        return MIDISystemCommand(rawValue: data.0)
    }
}

#endif
