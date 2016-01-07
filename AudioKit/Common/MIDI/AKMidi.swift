//
//  AKMidi.swift
//  AudioKit
//
//  Created by Jeff Cooper on 11/5/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import CoreMIDI

/// MIDI input and output handler
public class AKMidi {
    
    /// MIDI Client Reference
    public var midiClient = MIDIClientRef()
    
    /// Array of MIDI In ports
    public var midiInPorts: [MIDIPortRef] = []
    
    /// MIDI Client Name
    var midiClientName: CFString = "Midi Client"
    
    /// MIDI In Port Name
    var midiInName: CFString = "Midi In Port"
    
    /// MIDI End Point
    public var midiEndpoint: MIDIEndpointRef{
        return midiEndpoints[0]
    }
    
    /// Array of MIDI Out ports
    public var midiOutPorts: [MIDIPortRef] = []
    
    /// MIDI Out Port Reference
    public var midiOutPort = MIDIPortRef()
    
    /// Array of MIDI Endpoints
    public var midiEndpoints: [MIDIEndpointRef] = []
    
    /// MIDI Out Port Name
    var midiOutName: CFString = "Midi Out Port"
    
    private func MyMIDINotifyBlock(midiNotification: UnsafePointer<MIDINotification>) {
        let notification = midiNotification.memory
        print("MIDI Notify, messageId= \(notification.messageID.rawValue)")
        
    }
    
    private func MyMIDIReadBlock(
        packetList: UnsafePointer<MIDIPacketList>,
        srcConnRefCon: UnsafeMutablePointer<Void>) -> Void {
        /*
        //can't yet figure out how to access the port passed via srcConnRefCon
        //maybe having this port is not that necessary though...
        let midiPortPtr = UnsafeMutablePointer<MIDIPortRef>(srcConnRefCon)
        let midiPort = midiPortPtr.memory
        */
        let numPackets = Int(packetList.memory.numPackets)
        let packet = packetList.memory.packet as MIDIPacket
        var packetPtr: UnsafeMutablePointer<MIDIPacket> = UnsafeMutablePointer.alloc(1)
        packetPtr.initialize(packet)
        
        for var i = 0; i < numPackets; ++i {
            let event = AKMidiEvent(packet: packetPtr.memory)
            event.postNotification()
            packetPtr = MIDIPacketNext(packetPtr)
        }
    }
    
    /// Initialize the AKMidi system
    public init() {

        print("MIDI Enabled")
        #if os(iOS)
            MIDINetworkSession.defaultSession().enabled = true
            MIDINetworkSession.defaultSession().connectionPolicy =
                MIDINetworkConnectionPolicy.Anyone
        #endif
        var result = OSStatus(noErr)
        if midiClient == 0 {
            result = MIDIClientCreateWithBlock(midiClientName, &midiClient, MyMIDINotifyBlock)
            if result == OSStatus(noErr) {
                print("created client")
            } else {
                print("error creating client : \(result)")
            }
        }
    }
    
    /// Open a MIDI Input port
    ///
    /// - parameter namedInput: String containing the name of the MIDI Input
    ///
    public func openMidiIn(namedInput: String = "") {
        print("Opening Midi In")
        var result = OSStatus(noErr)
        
        let sourceCount = MIDIGetNumberOfSources()
        print("SourceCount: \(sourceCount)")
        for var i = 0; i < sourceCount; ++i {
            let src = MIDIGetSource(i)
            var inputName: Unmanaged<CFString>?
            inputName = nil
            MIDIObjectGetStringProperty(src, kMIDIPropertyName, &inputName)
            let inputNameStr = (inputName?.takeRetainedValue())! as String
            if namedInput.isEmpty || namedInput == inputNameStr {
                midiInPorts.append(MIDIPortRef())
                result = MIDIInputPortCreateWithBlock(
                    midiClient,
                    midiInName,
                    &midiInPorts[i],
                    MyMIDIReadBlock)
                if result == OSStatus(noErr) {
                    print("created midiInPort at \(inputNameStr)")
                } else {
                    print("error creating midiInPort : \(result)")
                }
                MIDIPortConnectSource(midiInPorts[i], src, nil)
            }
        }
    }
    
    /// Prints a list of all Midi Inputs
    public func printMidiInputs() {
        let sourceCount = MIDIGetNumberOfSources()
        print("Midi Inputs:")
        for var i = 0; i < sourceCount; ++i {
            let src = MIDIGetSource(i)
            var inputName: Unmanaged<CFString>?
            inputName = nil
            MIDIObjectGetStringProperty(src, kMIDIPropertyName, &inputName)
            let inputNameStr = (inputName?.takeRetainedValue())! as String
            print("midiIn at \(inputNameStr)")
        }
    }
    
    /// Open a MIDI Output Port
    ///
    /// - parameter namedOutput: String containing the name of the MIDI Input
    ///
    public func openMidiOut(namedOutput: String = "") {
        print("Opening Midi Out")
        var result = OSStatus(noErr)
        
        let numOutputs = MIDIGetNumberOfDestinations()
        print("Number of MIDI Out ports = \(numOutputs)")
        var foundDest = false
        result = MIDIOutputPortCreate(midiClient, midiOutName, &midiOutPort)
        
        if result == OSStatus(noErr) {
            print("created midi out port")
        } else {
            print("error creating midi out port : \(result)")
        }
        
        for var i = 0; i < numOutputs; ++i {
            let src = MIDIGetDestination(i)
            var endpointName: Unmanaged<CFString>?
            endpointName = nil
            MIDIObjectGetStringProperty(src, kMIDIPropertyName, &endpointName)
            let endpointNameStr = (endpointName?.takeRetainedValue())! as String
            if namedOutput.isEmpty || namedOutput == endpointNameStr {
                print("Found destination at \(endpointNameStr)")
                midiEndpoints.append(MIDIGetDestination(i))
                foundDest = true
            }
        }
        if !foundDest {
            print("no midi destination found named \"\(namedOutput)\"")
        }
    }
    
    /// Prints a list of all MIDI Destinations
    public func printMidiDestinations() {
        let numOutputs = MIDIGetNumberOfDestinations()
        print("Midi Destinations:")
        for var i = 0; i < numOutputs; ++i {
            let src = MIDIGetDestination(i)
            var endpointName: Unmanaged<CFString>?
            endpointName = nil
            MIDIObjectGetStringProperty(src, kMIDIPropertyName, &endpointName)
            let endpointNameStr = (endpointName?.takeRetainedValue())! as String
            print("Destination at \(endpointNameStr)")
        }//end foreach midi destination
    }
    
    /// Send Message with data
    public func sendMessage(data: [UInt8]) {
        var result = OSStatus(noErr)
        let packetListPtr: UnsafeMutablePointer<MIDIPacketList> = UnsafeMutablePointer.alloc(1)
        
        var packet = UnsafeMutablePointer<MIDIPacket>()
        packet = MIDIPacketListInit(packetListPtr)
        packet = MIDIPacketListAdd(packetListPtr, 1024, packet, 0, data.count, data)
        for var i = 0; i < midiEndpoints.count; ++i {
            result = MIDISend(midiOutPort, midiEndpoints[0], packetListPtr)
            if result == OSStatus(noErr) {
                //print("sent midi")
            } else {
                print("error sending midi : \(result)")
            }
        }
        
        packetListPtr.destroy()
        packetListPtr.dealloc(1)//necessary? wish i could do this without the alloc above
    }
    
    /// Send Messsage from midi event data
    public func sendMidiEvent(event: AKMidiEvent) {
        sendMessage(event.internalData)
    }
    
    /// Send a Note On Message
    public func sendNoteMessage(note: Int, velocity: Int, channel: Int = 0) {
        let noteCommand: UInt8 = UInt8(0x90) + UInt8(channel)
        let message: [UInt8] = [noteCommand, UInt8(note), UInt8(velocity)]
        self.sendMessage(message)
    }
    
    /// Send a Continuous Controller message
    public func sendControllerMessage(control: Int, value: Int, channel: Int = 0) {
        let controlCommand: UInt8 = UInt8(0xB0) + UInt8(channel)
        let message: [UInt8] = [controlCommand, UInt8(control), UInt8(value)]
        self.sendMessage(message)
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

/// Value of byte 2 in conjunction with AKMidiStatusControllerChange
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

/// Print out a more human readable error message
///
/// - parameter error: OSStatus flag
///
public func CheckError(error: OSStatus) {
    if error == 0 {return}
    switch error {
        // AudioToolbox
    case kAudio_ParamError:
        print("Error: kAudio_ParamError \n")
        
    case kAUGraphErr_NodeNotFound:
        print("Error: kAUGraphErr_NodeNotFound \n")
        
    case kAUGraphErr_OutputNodeErr:
        print( "Error: kAUGraphErr_OutputNodeErr \n")
        
    case kAUGraphErr_InvalidConnection:
        print("Error: kAUGraphErr_InvalidConnection \n")
        
    case kAUGraphErr_CannotDoInCurrentContext:
        print( "Error: kAUGraphErr_CannotDoInCurrentContext \n")
        
    case kAUGraphErr_InvalidAudioUnit:
        print( "Error: kAUGraphErr_InvalidAudioUnit \n")
        
    case kMIDIInvalidClient :
        print( "kMIDIInvalidClient ")
        
    case kMIDIInvalidPort :
        print( "Error: kMIDIInvalidPort ")
        
    case kMIDIWrongEndpointType :
        print( "Error: kMIDIWrongEndpointType")
        
    case kMIDINoConnection :
        print( "Error: kMIDINoConnection ")
        
    case kMIDIUnknownEndpoint :
        print( "Error: kMIDIUnknownEndpoint ")
        
    case kMIDIUnknownProperty :
        print( "Error: kMIDIUnknownProperty ")
        
    case kMIDIWrongPropertyType :
        print( "Error: kMIDIWrongPropertyType ")
        
    case kMIDINoCurrentSetup :
        print( "Error: kMIDINoCurrentSetup ")
        
    case kMIDIMessageSendErr :
        print( "kError: MIDIMessageSendErr ")
        
    case kMIDIServerStartErr :
        print( "kError: MIDIServerStartErr ")
        
    case kMIDISetupFormatErr :
        print( "Error: kMIDISetupFormatErr ")
        
    case kMIDIWrongThread :
        print( "Error: kMIDIWrongThread ")
        
    case kMIDIObjectNotFound :
        print( "Error: kMIDIObjectNotFound ")
        
    case kMIDIIDNotUnique :
        print( "Error: kMIDIIDNotUnique ")
        
    case kMIDINotPermitted:
        print( "Error: kMIDINotPermitted: Have you enabled the audio background mode in your ios app?")
        
    case kAudioToolboxErr_InvalidSequenceType :
        print( "Error: kAudioToolboxErr_InvalidSequenceType ")
        
    case kAudioToolboxErr_TrackIndexError :
        print( "Error: kAudioToolboxErr_TrackIndexError ")
        
    case kAudioToolboxErr_TrackNotFound :
        print( "Error: kAudioToolboxErr_TrackNotFound ")
        
    case kAudioToolboxErr_EndOfTrack :
        print( "Error: kAudioToolboxErr_EndOfTrack ")
        
    case kAudioToolboxErr_StartOfTrack :
        print( "Error: kAudioToolboxErr_StartOfTrack ")
        
    case kAudioToolboxErr_IllegalTrackDestination :
        print( "Error: kAudioToolboxErr_IllegalTrackDestination")
        
    case kAudioToolboxErr_NoSequence :
        print( "Error: kAudioToolboxErr_NoSequence ")
        
    case kAudioToolboxErr_InvalidEventType :
        print( "Error: kAudioToolboxErr_InvalidEventType")
        
    case kAudioToolboxErr_InvalidPlayerState :
        print( "Error: kAudioToolboxErr_InvalidPlayerState")
        
    case kAudioUnitErr_InvalidProperty :
        print( "Error: kAudioUnitErr_InvalidProperty")
        
    case kAudioUnitErr_InvalidParameter :
        print( "Error: kAudioUnitErr_InvalidParameter")
        
    case kAudioUnitErr_InvalidElement :
        print( "Error: kAudioUnitErr_InvalidElement")
        
    case kAudioUnitErr_NoConnection :
        print( "Error: kAudioUnitErr_NoConnection")
        
    case kAudioUnitErr_FailedInitialization :
        print( "Error: kAudioUnitErr_FailedInitialization")
        
    case kAudioUnitErr_TooManyFramesToProcess :
        print( "Error: kAudioUnitErr_TooManyFramesToProcess")
        
    case kAudioUnitErr_InvalidFile :
        print( "Error: kAudioUnitErr_InvalidFile")
        
    case kAudioUnitErr_FormatNotSupported :
        print( "Error: kAudioUnitErr_FormatNotSupported")
        
    case kAudioUnitErr_Uninitialized :
        print( "Error: kAudioUnitErr_Uninitialized")
        
    case kAudioUnitErr_InvalidScope :
        print( "Error: kAudioUnitErr_InvalidScope")
        
    case kAudioUnitErr_PropertyNotWritable :
        print( "Error: kAudioUnitErr_PropertyNotWritable")
        
    case kAudioUnitErr_InvalidPropertyValue :
        print( "Error: kAudioUnitErr_InvalidPropertyValue")
        
    case kAudioUnitErr_PropertyNotInUse :
        print( "Error: kAudioUnitErr_PropertyNotInUse")
        
    case kAudioUnitErr_Initialized :
        print( "Error: kAudioUnitErr_Initialized")
        
    case kAudioUnitErr_InvalidOfflineRender :
        print( "Error: kAudioUnitErr_InvalidOfflineRender")
        
    case kAudioUnitErr_Unauthorized :
        print( "Error: kAudioUnitErr_Unauthorized")
        
    default:
        print("Error: \(error)")
    }
}

// MARK: - MIDI Helpers

/// Extension to Int to calculate frequency from a MIDI Note Number
extension Int {
    
    /// Calculate frequency from a MIDI Note Number
    ///
    /// - returns: Frequency (Double) in Hz
    ///
    public func midiNoteToFrequency() -> Double {
        return pow(2.0, (Double(self) - 69.0) / 12.0) * 440.0
    }
}


/*
static void AKMIDIReadProc(const MIDIPacketList *pktlist, void *refCon, void *connRefCon)
{
AKMidi *m = (__bridge AKMidi *)refCon;

@autoreleasepool {
MIDIPacket *packet = (MIDIPacket *)pktlist->packet;
for (uint i = 0; i < pktlist->numPackets; i++) {
NSArray<AKMidiEvent *> *events = [AKMidiEvent midiEventsFromPacket: packet];

for (AKMidiEvent *event in events) {
if (event.command == AKMidiCommandClock)
continue;
if (m.forwardEvents) {
[m sendEvent: event];
}
[event postNotification];
}
packet = MIDIPacketNext(packet);
}
}
}
*/
