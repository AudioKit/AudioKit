//
//  AKMIDIControl.swift
//  AudioKit For OSX
//
//  Created by Aurelius Prochazka on 4/30/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

/// Value of byte 2 in conjunction with AKMIDIStatusControllerChange
///
/// - ModulationWheel: Modulation Control
/// - BreathControl: Breath Control (in MIDI Saxophones for example)
/// - FootControl: Foot Control
/// - Portamento: Portamento effect
/// - DataEntry: Data Entry
/// - MainVolume: Volume (Overall)
/// - Balance
/// - Pan: Stereo Panning
/// - Expression: Expression Pedal
/// - LSB: Least Significant Byte
/// - DamperOnOff: Damper Pedal, also known as Hold or Sustain
/// - PortamentoOnOff: Portamento Toggle
/// - SustenutoOnOff: Sustenuto Toggle
/// - SoftPedalOnOff: Soft Pedal Toggle
/// - DataEntryPlus: Data Entry Addition
/// - DataEntryMinus: Data Entry Subtraction
/// - LocalControlOnOff: Enable local control
/// - AllNotesOff: MIDI Panic
/// - CC# (0, 3, 9, 12-31) Unnamed Continuous Controllers
///
public enum AKMIDIControl: UInt8 {
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