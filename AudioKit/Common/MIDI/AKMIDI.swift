//
//  AKMIDI.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import CoreMIDI

/// MIDI input and output handler
///
/// You add midi listeners like this:
/// ```
/// var midiIn = AKMidi()
/// midi.openMIDIIn()
/// midi.addListener(someClass)
/// ```
/// ...where someClass conforms to the AKMIDIListener protocol
///
/// You then implement the methods you need from AKMIDIListener and use the data how you need.
public class AKMIDI {
    
    // MARK: - Properties
    
    /// MIDI Client Reference
    public var midiClient = MIDIClientRef()
    
    /// Array of MIDI In ports
    public var midiInPorts: [MIDIPortRef] = []
    
    /// MIDI Client Name
    var midiClientName: CFString = "MIDI Client"
    
    /// MIDI In Port Name
    var midiInName: CFString = "MIDI In Port"
    
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
    var midiOutName: CFString = "MIDI Out Port"
    
    /// Array of all listeners
    public var midiListeners:[AKMIDIListener] = []
    
    /// Add a listener to the listeners
    public func addListener(listener:AKMIDIListener){
        midiListeners.append(listener)
    }
    
    private func handleMidiMessage(event:AKMIDIEvent){
        for listener in midiListeners{
            let type = event.status
            switch type{
                case AKMIDIStatus.ControllerChange:
                    listener.midiController(Int(event.internalData[1]), value: Int(event.internalData[2]), channel: Int(event.channel))
                    break
                case AKMIDIStatus.ChannelAftertouch:
                    listener.midiAfterTouch(Int(event.internalData[1]), channel: Int(event.channel))
                    break
                case AKMIDIStatus.NoteOn:
                    listener.midiNoteOn(Int(event.internalData[1]), velocity: Int(event.internalData[2]), channel: Int(event.channel))
                    break
                case AKMIDIStatus.NoteOff:
                    listener.midiNoteOff(Int(event.internalData[1]), velocity: Int(event.internalData[2]), channel: Int(event.channel))
                    break
                case AKMIDIStatus.PitchWheel:
                    listener.midiPitchWheel(Int(event.internalData[1]), channel: Int(event.channel))
                    break
                case AKMIDIStatus.PolyphonicAftertouch:
                    listener.midiAftertouchOnNote(Int(event.internalData[1]), pressure: Int(event.internalData[2]), channel: Int(event.channel))
                    break
                case AKMIDIStatus.ProgramChange:
                    listener.midiProgramChange(Int(event.internalData[1]), channel: Int(event.channel))
                    break
                case AKMIDIStatus.SystemCommand:
                    listener.midiSystemCommand(event.internalData)
                    break
            }
        }
    }
    
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
            let event = AKMIDIEvent(packet: packetPtr.memory)
            handleMidiMessage(event)
            packetPtr = MIDIPacketNext(packetPtr)
        }
    
    }

    // MARK: - Initialization

    /// Initialize the AKMIDI system
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
    
    // MARK: - Input/Output Setup
    
    /// Open a MIDI Input port
    ///
    /// - parameter namedInput: String containing the name of the MIDI Input
    ///
    public func openMIDIIn(namedInput: String = "") {
        print("Opening MIDI In")
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
    
    /// Prints a list of all MIDI Inputs
    public func printMIDIInputs() {
        let sourceCount = MIDIGetNumberOfSources()
        print("MIDI Inputs:")
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
    public func openMIDIOut(namedOutput: String = "") {
        print("Opening MIDI Out")
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
    public func printMIDIDestinations() {
        let numOutputs = MIDIGetNumberOfDestinations()
        print("MIDI Destinations:")
        for var i = 0; i < numOutputs; ++i {
            let src = MIDIGetDestination(i)
            var endpointName: Unmanaged<CFString>?
            endpointName = nil
            MIDIObjectGetStringProperty(src, kMIDIPropertyName, &endpointName)
            let endpointNameStr = (endpointName?.takeRetainedValue())! as String
            print("Destination at \(endpointNameStr)")
        }//end foreach midi destination
    }
    
    // MARK: - Sending MIDI
    
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
    public func sendMIDIEvent(event: AKMIDIEvent) {
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
