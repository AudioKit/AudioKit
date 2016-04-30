//
//  AKMIDISystemCommand.swift
//  AudioKit For OSX
//
//  Created by Aurelius Prochazka on 4/30/16.
//  Copyright © 2016 AudioKit. All rights reserved.
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
public enum AKMIDISystemCommand: UInt8 {
    /// Trivial Case of None
    case None = 0
    /// System Exclusive
    case Sysex = 240
    /// Song Position
    case SongPosition = 242
    /// Song Selection
    case SongSelect = 243
    /// Request Tune
    case TuneRequest = 246
    /// End System Exclusive
    case SysexEnd = 247
    /// Clock
    case Clock = 248
    /// Start
    case Start = 250
    /// Continue
    case Continue = 251
    /// Stop
    case Stop = 252
    /// Active Sensing
    case ActiveSensing = 254
    /// System Reset
    case SysReset = 255
}