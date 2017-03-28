//
//  AKMIDISystemCommand.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
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
public enum AKMIDISystemCommand: MIDIByte {
    /// Trivial Case of None
    case none = 0
    /// System Exclusive
    case sysex = 240
    /// Song Position
    case songPosition = 242
    /// Song Selection
    case songSelect = 243
    /// Request Tune
    case tuneRequest = 246
    /// End System Exclusive
    case sysexEnd = 247
    /// Clock
    case clock = 248
    /// Start
    case start = 250
    /// Continue
    case `continue` = 251
    /// Stop
    case stop = 252
    /// Active Sensing
    case activeSensing = 254
    /// System Reset
    case sysReset = 255
}
