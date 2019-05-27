//
//  AKMIDISystemCommand.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// MIDI System Command
///
/// - None: Trivial Case
/// - Sysex: System Exclusive
/// - SongPosition: Song Position
/// - SongSelect: Song Selection
/// - TuneRequest: Request Tune
/// - SysexEnd: End System Exclusive
/// - Clock
/// - Start
/// - Continue
/// - Stop
/// - ActiveSensing: Active Sensing
/// - SysReset: System Reset
///
public enum AKMIDISystemCommand: MIDIByte, AKMIDIMessage {

    /// System Exclusive (Sysex)
    case sysex = 0xF0
    /// MIDI Time Code Quarter Frame (System Common)
    case timeCodeQuarterFrame = 0xF1
    /// Song Position Pointer (System Common)
    case songPosition = 0xF2
    /// Song Select (System Common)
    case songSelect = 0xF3
    /// Tune Request (System Common)
    case tuneRequest = 0xF6
    /// End System Exclusive (Sysex)
    case sysexEnd = 0xF7
    /// Timing Clock (System Realtime)
    case clock = 0xF8
    /// Start (System Realtime)
    case start = 0xFA
    /// Continue (System Realtime)
    case `continue` = 0xFB
    /// Stop (System Realtime)
    case stop = 0xFC
    /// Active Sensing (System Realtime)
    case activeSensing = 0xFE
    /// System Reset (System Realtime)
    case sysReset = 0xFF

    var type: AKMIDISystemCommandType {
        switch self {
        case .sysex, .sysexEnd:
            return .systemExclusive
        case .activeSensing, .clock, .continue, .start, .stop, .sysReset:
            return .systemRealtime
        case .songPosition, .songSelect, .timeCodeQuarterFrame, .tuneRequest:
            return .systemCommon
        }
    }

    var length: Int? {
        switch self {
        case .sysReset, .activeSensing, .start, .stop, .continue, .clock, .tuneRequest:
            return 1
        case .timeCodeQuarterFrame, .songSelect:
            return 2
        case .songPosition:
            return 3
        case .sysex, .sysexEnd:
            return nil
        }
    }

    public var description: String {
        switch self {
        case .sysex:
            return "Sysex Begin"
        case .timeCodeQuarterFrame:
            return "Timecode Quater Frame"
        case .songPosition:
            return "Song Position"
        case .songSelect:
            return "Song Selection"
        case .tuneRequest:
            return "Tune Request"
        case .sysexEnd:
            return "Sysex End"
        case .clock:
            return "Timing Clock"
        case .start:
            return "Start"
        case .continue:
            return "Continue"
        case .stop:
            return "Stop"
        case .activeSensing:
            return "Active Sensing"
        case .sysReset:
            return "System Reset"
        }
    }

    public var byte: MIDIByte {
        return rawValue
    }

    public var data: [UInt8] {
        return [byte]
    }
}

public enum AKMIDISystemCommandType {
    case systemRealtime
    case systemCommon
    case systemExclusive

    var description: String {
        switch self {
        case .systemRealtime:
            return "System Realtime"
        case .systemCommon:
            return "System Common"
        case .systemExclusive:
            return "System Exclusive"
        }
    }
}
