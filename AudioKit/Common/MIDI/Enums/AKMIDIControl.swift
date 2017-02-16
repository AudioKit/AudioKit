//
//  AKMIDIControl.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
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
public enum AKMIDIControl: MIDIByte {
    /// Modulation Control
    case modulationWheel = 1
    /// Breath Control (in MIDI Saxophones for example)
    case breathControl = 2
    /// Foot Control
    case footControl = 4
    /// Portamento effect
    case portamento = 5
    /// Data Entry
    case dataEntry = 6
    /// Volume (Overall)
    case mainVolume = 7
    /// Balance
    case balance = 8
    /// Stereo Panning
    case pan = 10
    /// Expression Pedal
    case expression = 11

    /// Least Significant Byte
    case lsb = 32 // Combine with above constants to get the LSB

    /// Damper Pedal, also known as Hold or Sustain
    case damperOnOff = 64
    /// Portamento Toggle
    case portamentoOnOff = 65
    /// Sustenuto Toggle
    case sustenutoOnOff = 66
    /// Soft Pedal Toggle
    case softPedalOnOff = 67

    /// Data Entry Addition
    case dataEntryPlus = 96
    /// Data Entry Subtraction
    case dataEntryMinus = 97

    /// Enable local control
    case localControlOnOff = 122
    /// MIDI Panic
    case allNotesOff = 123

    // Unnamed CC values: (Must be a better way)

    /// Continuous Controller Number 0
    case cc0 = 0
    /// Continuous Controller Number 3
    case cc3 = 3
    /// Continuous Controller Number 9
    case cc9 = 9
    /// Continuous Controller Number 12
    case cc12 = 12
    /// Continuous Controller Number 13
    case cc13 = 13
    /// Continuous Controller Number 14
    case cc14 = 14
    /// Continuous Controller Number 15
    case cc15 = 15
    /// Continuous Controller Number 16
    case cc16 = 16
    /// Continuous Controller Number 17
    case cc17 = 17
    /// Continuous Controller Number 18
    case cc18 = 18
    /// Continuous Controller Number 19
    case cc19 = 19
    /// Continuous Controller Number 20
    case cc20 = 20
    /// Continuous Controller Number 21
    case cc21 = 21
    /// Continuous Controller Number 22
    case cc22 = 22
    /// Continuous Controller Number 23
    case cc23 = 23
    /// Continuous Controller Number 24
    case cc24 = 24
    /// Continuous Controller Number 25
    case cc25 = 25
    /// Continuous Controller Number 26
    case cc26 = 26
    /// Continuous Controller Number 27
    case cc27 = 27
    /// Continuous Controller Number 28
    case cc28 = 28
    /// Continuous Controller Number 29
    case cc29 = 29
    /// Continuous Controller Number 30
    case cc30 = 30
    /// Continuous Controller Number 31
    case cc31 = 31
}
