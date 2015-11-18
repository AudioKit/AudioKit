//
//  AudioKitHelpers.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/14/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

/** Potential MIDI Status messages

 - NoteOff: something resembling a keyboard key release
 - NoteOn: triggered when a new note is created, or a keyboard key press
 - PolyphonicAftertouch: rare MIDI control on controllers in which every key has separate touch sensing
 - ControllerChange: wide range of control types including volume, expression, modulation and a host of unnamed controllers with numbers
 - ProgramChange: messages are associated with changing the basic character of the sound preset
 - ChannelAftertouch: single aftertouch for all notes on a given channel (most common aftertouch type in keyboards)
 - PitchWheel: common keyboard control that allow for a pitch to be bent up or down a given number of semitones
 - SystemCommand: differ from system to system
*/
enum AKMidiStatus : Int {
    /// Note off is something resembling a keyboard key release
    case NoteOff = 8
    /// Note on is triggered when a new note is created, or a keyboard key press
    case NoteOn = 9
    /// Polyphonic aftertouch is a rare MIDI control on controllers in which every key has separate touch sensing
    case PolyphonicAftertouch = 10
    /// Controller changes represent a wide range of control types including volume, expression, modulation and a host of unnamed controllers with numbers
    case ControllerChange = 11
    /// Program change messages are associated with changing the basic character of the sound preset
    case ProgramChange = 12
    /// A single aftertouch for all notes on a given channel (most common aftertouch type in keyboards)
    case ChannelAftertouch = 13
    /// A pitch wheel is a common keyboard control that allow for a pitch to be bent up or down a given number of semitones
    case PitchWheel = 14
    /// System commands differ from system to system
    case SystemCommand = 15
    
    /// Return a unique string for use as broadcasted name in NSNotificationCenter
    func name() -> String {
        return "AudioKit Midi Status: \(self)"
    }
}

/** MIDI System Command
 - None: Trivial Case
 - Sysex: System Exclusive
 - SongPosition: Song Position
 - SongSelect: Song Selection
 - TuneRequest: Request Tune
 - SysexEnd: End System Exclusive
 - Clock
 - Start
 - Continue
 - Stop
 - ActiveSensing: Active Sensing
 - SysReset: System Reset
 */
enum AKMidiSystemCommand : UInt8 {
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

/// Value of byte 2 in conjunction with AKMidiStatusControllerChange
enum AKMidiControl : UInt8 {
    /// Modulation Control
    case ModulationWheel = 1
    /// Breath Control (in MIDI Saxophones for example)
    case BreathControl = 2
    /// Foot Control
    case FootControl = 4
    /// Portamento effect
    case Portamento = 5
    /// Data Entry
    case DataEntry = 6
    /// Volume (Overall)
    case MainVolume = 7
    /// Balance
    case Balance = 8
    /// Stereo Panning
    case Pan = 10
    /// Expression Pedal
    case Expression = 11
    
    /// Least Significant Byte
    case LSB               = 32 // Combine with above constants to get the LSB
    
    /// Damper Pedal, also known as Hold or Sustain
    case DamperOnOff       = 64
    /// Portamento Toggle
    case PortamentoOnOff   = 65
    /// Sustenuto Toggle
    case SustenutoOnOff    = 66
    /// Soft Pedal Toggle
    case SoftPedalOnOff    = 67
    
    /// Data Entry Addition
    case DataEntryPlus     = 96
    /// Data Entry Subtraction
    case DataEntryMinus    = 97
    
    /// Enable local control
    case LocalControlOnOff = 122
    /// MIDI Panic
    case AllNotesOff       = 123
    
    // Unnamed CC values: (Must be a better way)
    
    /// Continuous Controller Number 0
    case CC0  = 0
    /// Continuous Controller Number 3
    case CC3  = 3
    /// Continuous Controller Number 9
    case CC9  = 9
    /// Continuous Controller Number 12
    case CC12 = 12
    /// Continuous Controller Number 13
    case CC13 = 13
    /// Continuous Controller Number 14
    case CC14 = 14
    /// Continuous Controller Number 15
    case CC15 = 15
    /// Continuous Controller Number 16
    case CC16 = 16
    /// Continuous Controller Number 17
    case CC17 = 17
    /// Continuous Controller Number 18
    case CC18 = 18
    /// Continuous Controller Number 19
    case CC19 = 19
    /// Continuous Controller Number 20
    case CC20 = 20
    /// Continuous Controller Number 21
    case CC21 = 21
    /// Continuous Controller Number 22
    case CC22 = 22
    /// Continuous Controller Number 23
    case CC23 = 23
    /// Continuous Controller Number 24
    case CC24 = 24
    /// Continuous Controller Number 25
    case CC25 = 25
    /// Continuous Controller Number 26
    case CC26 = 26
    /// Continuous Controller Number 27
    case CC27 = 27
    /// Continuous Controller Number 28
    case CC28 = 28
    /// Continuous Controller Number 29
    case CC29 = 29
    /// Continuous Controller Number 30
    case CC30 = 30
    /// Continuous Controller Number 31
    case CC31 = 31
}
