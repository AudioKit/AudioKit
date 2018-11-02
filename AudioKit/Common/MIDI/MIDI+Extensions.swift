//
//  MIDIByte+Extensions.swift
//  AudioKit
//
//  Created by Jeff Cooper on 10/31/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

public typealias MIDIByte = UInt8
public typealias MIDIWord = UInt16
public typealias MIDINoteNumber = UInt8
public typealias MIDIVelocity = UInt8
public typealias MIDIChannel = UInt8

extension MIDIByte {
    /// This limits the range to be from 0 to 127
    func lower7bits() -> MIDIByte {
        return self & 0x7F
    }

    /// This limits the range to be from 0 to 16
    var lowBit: MIDIByte {
        return self & 0xF
    }

    var highBit: MIDIByte {
        return self >> 4
    }
}

extension MIDIPacket {
    var isSysex: Bool {
        return data.0 == AKMIDISystemCommand.sysex.rawValue
    }

    var status: AKMIDIStatusType? {
        return AKMIDIStatusType(rawValue: Int(data.0.highBit))
    }

    var channel: MIDIChannel {
        return data.0.lowBit
    }

    var command: AKMIDISystemCommand? {
        return AKMIDISystemCommand(rawValue: data.0)
    }
}

enum MIDITimeFormat: Int {
    case ticksPerBeat = 0
    case framesPerSecond = 1

    var description: String {
        switch self {
        case .ticksPerBeat:
            return "TicksPerBeat"
        case .framesPerSecond:
            return "FramesPerSecond"
        }
    }
}
