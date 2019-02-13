//
//  MIDIPacket+Extensions.swift
//  AudioKit
//
//  Created by Kurt Arnlund on 1/18/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import CoreMIDI

extension MIDIPacket {
    var isSysex: Bool {
        return data.0 == AKMIDISystemCommand.sysex.rawValue
    }

    var status: AKMIDIStatus? {
        return AKMIDIStatus(byte: data.0)
    }

    var channel: MIDIChannel {
        return data.0.lowBit
    }

    var isSystemCommand: Bool {
        return data.0 >= 0xf0
    }

    var systemCommand: AKMIDISystemCommand? {
        return AKMIDISystemCommand(rawValue: data.0)
    }
}
