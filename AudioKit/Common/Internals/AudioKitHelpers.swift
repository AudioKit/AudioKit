//
//  AudioKitHelpers.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import CoreAudio
import AudioToolbox

// MARK: - Randomization Helpers

/// Global function for random integers
///
/// - returns: Random integer in the range
/// - parameter range: Range of valid integers to choose from
///
public func randomInt(range: Range<Int>) -> Int {
    let width = range.maxElement()! - range.minElement()!
    return Int(arc4random_uniform(UInt32(width))) + range.minElement()!
}

/// Extension to Array for Random Element
extension Array {
    
    /// Return a random element from the array
    public func randomElement() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}

/// Global function for random Doubles
///
/// - returns: Random double between bounds
/// - parameter minimum: Lower bound of randomization
/// - parameter maximum: Upper bound of randomization
///
public func random(minimum: Double, _ maximum: Double) -> Double {
    let precision = 1000000
    let width = maximum - minimum
    
    return Double(arc4random_uniform(UInt32(precision))) / Double(precision) * width + minimum
}

// MARK: - Normalization Helpers

/// Extension to calculate scaling factors, useful for UI controls
extension Double {
    
    /// Convert a value on [min, max] to a [0, 1] range, according to a taper
    ///
    /// - parameter min: Minimum of the source range (cannot be zero if taper is not positive)
    /// - parameter max: Maximum of the source range
    /// - parameter taper: For taper > 0, there is an algebraic curve, taper = 1 is linear, and taper < 0 is exponential
    ///
    public mutating func normalize(min: Double, max: Double, taper: Double) {
        if taper > 0 {
            // algebraic taper
            self = pow(((self - min) / (max - min)), (1.0 / taper))
        } else {
            // exponential taper
            self = log(self / min) / log(max / min)
        }
    }
    
    /// Convert a value on [0, 1] to a [min, max] range, according to a taper
    ///
    /// - parameter min: Minimum of the target range (cannot be zero if taper is not positive)
    /// - parameter max: Maximum of the target range
    /// - parameter taper: For taper > 0, there is an algebraic curve, taper = 1 is linear, and taper < 0 is exponential
    ///
    public mutating func denormalize(min: Double, max: Double, taper: Double) {
        if taper > 0 {
            // algebraic taper
            self = min + (max - min) * pow(self, taper)
        } else {
            // exponential taper
            self = min * exp(log(max / min) * self)
        }
    }
    
    /// Calculate frequency from a floating point MIDI Note Number
    ///
    /// - returns: Frequency (Double) in Hz
    ///
    public func midiNoteToFrequency(aRef: Double = 440.0) -> Double {
        return pow(2.0, (self - 69.0) / 12.0) * aRef
    }

}

// MARK: - MIDI Helpers

/// Extension to Int to calculate frequency from a MIDI Note Number
extension Int {
    
    /// Calculate frequency from a MIDI Note Number
    ///
    /// - returns: Frequency (Double) in Hz
    ///
    public func midiNoteToFrequency(aRef: Double = 440.0) -> Double {
        return pow(2.0, (Double(self) - 69.0) / 12.0) * aRef
    }
}



/// Potential MIDI Status messages
///
/// - NoteOff:
///    something resembling a keyboard key release
/// - NoteOn:
///    triggered when a new note is created, or a keyboard key press
/// - PolyphonicAftertouch:
///    rare MIDI control on controllers in which every key has separate touch sensing
/// - ControllerChange:
///    wide range of control types including volume, expression, modulation
///    and a host of unnamed controllers with numbers
/// - ProgramChange:
///    messages are associated with changing the basic character of the sound preset
/// - ChannelAftertouch:
///    single aftertouch for all notes on a given channel (most common aftertouch type in keyboards)
/// - PitchWheel:
///    common keyboard control that allow for a pitch to be bent up or down a given number of semitones
/// - SystemCommand:
///    differ from system to system
///
public enum AKMIDIStatus: Int {
    /// Note off is something resembling a keyboard key release
    case NoteOff = 8
    /// Note on is triggered when a new note is created, or a keyboard key press
    case NoteOn = 9
    /// Polyphonic aftertouch is a rare MIDI control on controllers in which
    /// every key has separate touch sensing
    case PolyphonicAftertouch = 10
    /// Controller changes represent a wide range of control types including volume,
    /// expression, modulation and a host of unnamed controllers with numbers
    case ControllerChange = 11
    /// Program change messages are associated with changing the basic character of the sound preset
    case ProgramChange = 12
    /// A single aftertouch for all notes on a given channel
    /// (most common aftertouch type in keyboards)
    case ChannelAftertouch = 13
    /// A pitch wheel is a common keyboard control that allow for a pitch to be
    /// bent up or down a given number of semitones
    case PitchWheel = 14
    /// System commands differ from system to system
    case SystemCommand = 15
    
}

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
