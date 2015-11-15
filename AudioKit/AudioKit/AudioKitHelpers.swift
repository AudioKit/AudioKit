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

enum AKMidiSystemCommand : UInt8 {
    case None          = 0
    case Sysex         = 240
    case SongPosition  = 242
    case SongSelect    = 243
    case TuneRequest   = 246
    case SysexEnd      = 247
    case Clock         = 248
    case Start         = 250
    case Continue      = 251
    case Stop          = 252
    case ActiveSensing = 254
    case SysReset      = 255
}

/// Value of byte 2 in conjunction with AKMidiStatusControllerChange
enum AKMidiControl : UInt8 {
    case ModulationWheel   = 1
    case BreathControl     = 2
    case FootControl       = 4
    case Portamento        = 5
    case DataEntry         = 6
    case MainVolume        = 7
    case Balance           = 8
    case Pan               = 10
    case Expression        = 11
    
    case LSB               = 32 // Combine with above constants to get the LSB
    
    case DamperOnOff       = 64
    case PortamentoOnOff   = 65
    case SustenutoOnOff    = 66
    case SoftPedalOnOff    = 67
    
    case DataEntryPlus     = 96
    case DataEntryMinus    = 97
    
    case LocalControlOnOff = 122
    case AllNotesOff       = 123
    
    // Unnamed CC values: (Must be a better way)
    case CC0  = 0
    case CC3  = 3
    case CC9  = 9
    case CC12 = 12
    case CC13 = 13
    case CC14 = 14
    case CC15 = 15
    case CC16 = 16
    case CC17 = 17
    case CC18 = 18
    case CC19 = 19
    case CC20 = 20
    case CC21 = 21
    case CC22 = 22
    case CC23 = 23
    case CC24 = 24
    case CC25 = 25
    case CC26 = 26
    case CC27 = 27
    case CC28 = 28
    case CC29 = 29
    case CC30 = 30
    case CC31 = 31
}

enum AKMidiNotification {
    case NoteOn
    case NoteOff
    case PolyphonicAftertouch
    case ProgramChange
    case Aftertouch
    case PitchWheel
    case Controller
    case Modulation
    case Portamento
    case Volume
    case Balance
    case Pan
    case Expression
    case Control  // Is this different than controller above?
    
    func name() -> String {
        return "AudioKit Midi Notification: \(self)"
    }
}