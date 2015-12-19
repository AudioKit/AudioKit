//
//  AudioKitHelpers.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/14/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import CoreAudio
import AudioToolbox

extension Int {
    public func midiNoteToFrequency() -> Double {
        return pow(2.0, (Double(self) - 69.0) / 12.0) * 440.0
    }
}
extension Float {
    public mutating func randomize(minimum: Float, _ maximum: Float) {
        self = randomFloat(minimum, maximum)
    }
}

public func randomFloat(minimum: Float, _ maximum: Float) -> Float {
    let precision = 1000000
    let width = maximum - minimum
    
    return Float(arc4random_uniform(UInt32(precision))) / Float(precision) * width + minimum
}

extension Array {
    public func randomElement() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}

public func randomInt(range: Range<Int>) -> Int {
    let width = range.maxElement()! - range.minElement()!
    return Int(arc4random_uniform(UInt32(width))) + range.minElement()!
}


/** Potential MIDI Status messages

 - NoteOff: 
    something resembling a keyboard key release
 - NoteOn: 
    triggered when a new note is created, or a keyboard key press
 - PolyphonicAftertouch: 
    rare MIDI control on controllers in which every key has separate touch sensing
 - ControllerChange: 
    wide range of control types including volume, expression, modulation 
    and a host of unnamed controllers with numbers
 - ProgramChange: 
    messages are associated with changing the basic character of the sound preset
 - ChannelAftertouch: 
    single aftertouch for all notes on a given channel (most common aftertouch type in keyboards)
 - PitchWheel: 
    common keyboard control that allow for a pitch to be bent up or down a given number of semitones
 - SystemCommand: 
    differ from system to system
*/
public enum AKMidiStatus: Int {
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
    
    /// Return a unique string for use as broadcasted name in NSNotificationCenter
    public func name() -> String {
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
public enum AKMidiSystemCommand: UInt8 {
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

/** Value of byte 2 in conjunction with AKMidiStatusControllerChange
 
 - ModulationWheel: Modulation Control
 - BreathControl: Breath Control (in MIDI Saxophones for example)
 - FootControl: Foot Control
 - Portamento: Portamento effect
 - DataEntry: Data Entry
 - MainVolume: Volume (Overall)
 - Balance
 - Pan: Stereo Panning
 - Expression: Expression Pedal
 - LSB: Least Significant Byte
 - DamperOnOff: Damper Pedal, also known as Hold or Sustain
 - PortamentoOnOff: Portamento Toggle
 - SustenutoOnOff: Sustenuto Toggle
 - SoftPedalOnOff: Soft Pedal Toggle
 - DataEntryPlus: Data Entry Addition
 - DataEntryMinus: Data Entry Subtraction
 - LocalControlOnOff: Enable local control
 - AllNotesOff: MIDI Panic
 - CC# (0, 3, 9, 12-31) Unnamed Continuous Controllers
 */
public enum AKMidiControl: UInt8 {
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
public func CheckError(error: OSStatus) {
    if error == 0 {return}
    switch error {
    // AudioToolbox
    case kAudio_ParamError:
        print("Error:kAudio_ParamError \n")
        
    case kAUGraphErr_NodeNotFound:
        print("Error:kAUGraphErr_NodeNotFound \n")
        
    case kAUGraphErr_OutputNodeErr:
        print( "Error:kAUGraphErr_OutputNodeErr \n")
        
    case kAUGraphErr_InvalidConnection:
        print("Error:kAUGraphErr_InvalidConnection \n")
        
    case kAUGraphErr_CannotDoInCurrentContext:
        print( "Error:kAUGraphErr_CannotDoInCurrentContext \n")
        
    case kAUGraphErr_InvalidAudioUnit:
        print( "Error:kAUGraphErr_InvalidAudioUnit \n")
        
    case kMIDIInvalidClient :
        print( "kMIDIInvalidClient ")
        
    case kMIDIInvalidPort :
        print( "kMIDIInvalidPort ")
        
    case kMIDIWrongEndpointType :
        print( "kMIDIWrongEndpointType")
        
    case kMIDINoConnection :
        print( "kMIDINoConnection ")
        
    case kMIDIUnknownEndpoint :
        print( "kMIDIUnknownEndpoint ")
        
    case kMIDIUnknownProperty :
        print( "kMIDIUnknownProperty ")
        
    case kMIDIWrongPropertyType :
        print( "kMIDIWrongPropertyType ")
        
    case kMIDINoCurrentSetup :
        print( "kMIDINoCurrentSetup ")
        
    case kMIDIMessageSendErr :
        print( "kMIDIMessageSendErr ")
        
    case kMIDIServerStartErr :
        print( "kMIDIServerStartErr ")
        
    case kMIDISetupFormatErr :
        print( "kMIDISetupFormatErr ")
        
    case kMIDIWrongThread :
        print( "kMIDIWrongThread ")
        
    case kMIDIObjectNotFound :
        print( "kMIDIObjectNotFound ")
        
    case kMIDIIDNotUnique :
        print( "kMIDIIDNotUnique ")
        
    case kAudioToolboxErr_InvalidSequenceType :
        print( " kAudioToolboxErr_InvalidSequenceType ")
        
    case kAudioToolboxErr_TrackIndexError :
        print( " kAudioToolboxErr_TrackIndexError ")
        
    case kAudioToolboxErr_TrackNotFound :
        print( " kAudioToolboxErr_TrackNotFound ")
        
    case kAudioToolboxErr_EndOfTrack :
        print( " kAudioToolboxErr_EndOfTrack ")
        
    case kAudioToolboxErr_StartOfTrack :
        print( " kAudioToolboxErr_StartOfTrack ")
        
    case kAudioToolboxErr_IllegalTrackDestination :
        print( " kAudioToolboxErr_IllegalTrackDestination")
        
    case kAudioToolboxErr_NoSequence :
        print( " kAudioToolboxErr_NoSequence ")
        
    case kAudioToolboxErr_InvalidEventType :
        print( " kAudioToolboxErr_InvalidEventType")
        
    case kAudioToolboxErr_InvalidPlayerState :
        print( " kAudioToolboxErr_InvalidPlayerState")
        
    case kAudioUnitErr_InvalidProperty :
        print( " kAudioUnitErr_InvalidProperty")
        
    case kAudioUnitErr_InvalidParameter :
        print( " kAudioUnitErr_InvalidParameter")
        
    case kAudioUnitErr_InvalidElement :
        print( " kAudioUnitErr_InvalidElement")
        
    case kAudioUnitErr_NoConnection :
        print( " kAudioUnitErr_NoConnection")
        
    case kAudioUnitErr_FailedInitialization :
        print( " kAudioUnitErr_FailedInitialization")
        
    case kAudioUnitErr_TooManyFramesToProcess :
        print( " kAudioUnitErr_TooManyFramesToProcess")
        
    case kAudioUnitErr_InvalidFile :
        print( " kAudioUnitErr_InvalidFile")
        
    case kAudioUnitErr_FormatNotSupported :
        print( " kAudioUnitErr_FormatNotSupported")
        
    case kAudioUnitErr_Uninitialized :
        print( " kAudioUnitErr_Uninitialized")
        
    case kAudioUnitErr_InvalidScope :
        print( " kAudioUnitErr_InvalidScope")
        
    case kAudioUnitErr_PropertyNotWritable :
        print( " kAudioUnitErr_PropertyNotWritable")
        
    case kAudioUnitErr_InvalidPropertyValue :
        print( " kAudioUnitErr_InvalidPropertyValue")
        
    case kAudioUnitErr_PropertyNotInUse :
        print( " kAudioUnitErr_PropertyNotInUse")
        
    case kAudioUnitErr_Initialized :
        print( " kAudioUnitErr_Initialized")
        
    case kAudioUnitErr_InvalidOfflineRender :
        print( " kAudioUnitErr_InvalidOfflineRender")
        
    case kAudioUnitErr_Unauthorized :
        print( " kAudioUnitErr_Unauthorized")
        
    default:
        print("Error: \(error)")
    }
}
