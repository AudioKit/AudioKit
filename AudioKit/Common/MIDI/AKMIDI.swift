//
//  AKMIDI.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import CoreMIDI


/// Temporary hack for Xcode 7.3.1 - Appreciate improvements to this if you want to make a go of it!
typealias AKRawMIDIPacket = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)


/// The returned generator will enumerate each value of the provided tuple.
func generatorForTuple(tuple: AKRawMIDIPacket) -> AnyGenerator<Any> {
    let children = Mirror(reflecting: tuple).children
    return AnyGenerator(children.generate().lazy.map { $0.value }.generate())
}

/**
 Allows a MIDIPacket to be iterated through with a for statement.
 This is necessary because MIDIPacket can contain multiple midi events,
 but Swift makes this unnecessarily hard because the MIDIPacket struct uses a tuple
 for the data field. Grrr!
 
 Example usage:
 let packet: MIDIPacket
 for message in packet {
 // message is a Message
 }
 */
extension MIDIPacket: SequenceType {
    /// Generate a midi packet
    public func generate() -> AnyGenerator<AKMIDIEvent> {
        let generator = generatorForTuple(self.data)
        var index: UInt16 = 0
        
        return AnyGenerator {
            if index >= self.length {
                return nil
            }
            
            func pop() -> UInt8 {
                assert(index < self.length)
                index += 1
                return generator.next() as! UInt8
            }
            
            let status = pop()
            if AKMIDIEvent.isStatusByte(status) {
                var data1: UInt8 = 0
                var data2: UInt8 = 0
                var mstat = AKMIDIEvent.statusFromValue(status)
                switch  mstat {
                case .NoteOff,
                .NoteOn,
                .PolyphonicAftertouch,
                .ControllerChange,
                .PitchWheel:
                    data1 = pop(); data2 = pop()

                case .ProgramChange,
                .ChannelAftertouch:
                    data1 = pop()

                case .SystemCommand: break
                }

                if mstat == .NoteOn && data2 == 0 {
                    // turn noteOn with velocity 0 to noteOff
                    mstat = .NoteOff
                }

                let chan = (status & 0xF)
                return AKMIDIEvent(status: mstat, channel: chan, byte1: data1, byte2: data2)
            } else if status == 0xF0 {
                // sysex - guaranteed by coremidi to be the entire packet
                index = self.length
                return AKMIDIEvent(packet: self)
            } else {
                let cmd = AKMIDISystemCommand(rawValue: status)!
                var data1: UInt8 = 0
                var data2: UInt8 = 0
                switch  cmd {
                case .Sysex: break
                case .SongPosition:
                    data1 = pop()
                    data2 = pop()
                case .SongSelect:
                    data1 = pop()
                default: break
                }
                
                return AKMIDIEvent(command: cmd, byte1: data1, byte2: data2)
            }
        }
    }
}

extension MIDIPacketList: SequenceType {
    /// Type alis for MIDI Packet List Generator
    public typealias Generator = MIDIPacketListGenerator
    
    /// Create a generator from the packet list
    public func generate() -> Generator {
        return Generator(packetList: self)
    }
}

/// Generator for MIDIPacketList allowing iteration over its list of MIDIPacket objects.
public struct MIDIPacketListGenerator: GeneratorType {
    public typealias Element = MIDIPacket
    
    /// Initialize the packet list generator with a packet list
    ///
    /// - parameter packetList: MIDI Packet List
    ///
    init(packetList: MIDIPacketList) {
        let ptr = UnsafeMutablePointer<MIDIPacket>.alloc(1)
        ptr.initialize(packetList.packet)
        self.packet = ptr
        self.count = packetList.numPackets
    }
    
    /// Provide the next element (packet)
    public mutating func next() -> Element? {
        guard self.packet != nil && self.index < self.count else { return nil }
        
        let lastPacket = self.packet!
        self.packet = MIDIPacketNext(self.packet!)
        self.index += 1
        return lastPacket.memory
    }
    
    // Extracted packet list info
    var count: UInt32
    var index: UInt32 = 0
    
    // Iteration state
    var packet: UnsafeMutablePointer<MIDIPacket>?
}

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

    /// Virtual MIDI Input destination
    public var virtualInput = MIDIPortRef()

    /// MIDI Client Name
    var midiClientName: CFString = "MIDI Client"
    
    /// MIDI In Port Name
    var midiInName: CFString = "MIDI In Port"
    
    /// MIDI End Point
    public var midiEndpoint: MIDIEndpointRef {
        return midiEndpoints[0]
    }
    
    /// Array of MIDI Out ports
    public var midiOutPorts: [MIDIPortRef] = []
    
    /// MIDI Out Port Reference
    public var midiOutPort = MIDIPortRef()

    /// Virtual MIDI output
    public var virtualOutput = MIDIPortRef()

    
    /// Array of MIDI Endpoints
    public var midiEndpoints: [MIDIEndpointRef] = []
    
    /// MIDI Out Port Name
    var midiOutName: CFString = "MIDI Out Port"
    
    /// Array of all listeners
    public var midiListeners: [AKMIDIListener] = []
    
    /// Add a listener to the listeners
    public func addListener(listener: AKMIDIListener) {
        midiListeners.append(listener)
    }
    
    private func handleMidiMessage(event: AKMIDIEvent) {
        for listener in midiListeners {
            let type = event.status
            switch type {
                case AKMIDIStatus.ControllerChange:
                    listener.midiController(Int(event.internalData[1]), value: Int(event.internalData[2]), channel: Int(event.channel))
                case AKMIDIStatus.ChannelAftertouch:
                    listener.midiAfterTouch(Int(event.internalData[1]), channel: Int(event.channel))
                case AKMIDIStatus.NoteOn:
                    listener.midiNoteOn(Int(event.internalData[1]), velocity: Int(event.internalData[2]), channel: Int(event.channel))
                case AKMIDIStatus.NoteOff:
                    listener.midiNoteOff(Int(event.internalData[1]), velocity: Int(event.internalData[2]), channel: Int(event.channel))
                case AKMIDIStatus.PitchWheel:
                    listener.midiPitchWheel(Int(event.data), channel: Int(event.channel))
                case AKMIDIStatus.PolyphonicAftertouch:
                    listener.midiAftertouchOnNote(Int(event.internalData[1]), pressure: Int(event.internalData[2]), channel: Int(event.channel))
                case AKMIDIStatus.ProgramChange:
                    listener.midiProgramChange(Int(event.internalData[1]), channel: Int(event.channel))
                case AKMIDIStatus.SystemCommand:
                    listener.midiSystemCommand(event.internalData)
            }
        }
    }
    
    private func MyMIDINotifyBlock(midiNotification: UnsafePointer<MIDINotification>) {
        _ = midiNotification.memory
        //do something with notification - change _ above to let varname
        //print("MIDI Notify, messageId= \(notification.messageID.rawValue)")
        
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

        for packet in packetList.memory {
            // a coremidi packet may contain multiple midi events
            for event in packet {
                handleMidiMessage(event)
            }
        }
    }

    // MARK: - Initialization

    /// Initialize the AKMIDI system
    public init() {

        //print("MIDI Enabled")
        #if os(iOS)
            MIDINetworkSession.defaultSession().enabled = true
            MIDINetworkSession.defaultSession().connectionPolicy =
                MIDINetworkConnectionPolicy.Anyone
        #endif
        var result = OSStatus(noErr)
        if midiClient == 0 {
            result = MIDIClientCreateWithBlock(midiClientName, &midiClient, MyMIDINotifyBlock)
            if result == OSStatus(noErr) {
                print("created midi client")
            } else {
                print("error creating midi client : \(result)")
            }
        }
    }
    
    /// Create set of virtual MIDI ports
    public func createVirtualPorts(uniqueId: Int32 = 2000000) {
        //print("Creating virtual MIDI ports")

        destroyVirtualPorts()
        
        var result = OSStatus(noErr)
        result = MIDIDestinationCreateWithBlock(midiClient, midiClientName, &virtualInput, MyMIDIReadBlock)
        
        if result == OSStatus(noErr) {
            print("Created virt dest: \(midiClientName)")
            MIDIObjectSetIntegerProperty(virtualInput, kMIDIPropertyUniqueID, uniqueId)
        } else {
            print("Error creatervirt dest: \(midiClientName) -- \(virtualInput)")
        }
        
        
        result = MIDISourceCreate(midiClient, midiClientName, &virtualOutput)
        if result == OSStatus(noErr) {
            print("Created virt source: \(midiClientName)")
            MIDIObjectSetIntegerProperty(virtualInput, kMIDIPropertyUniqueID, uniqueId + 1)
        } else {
            print("Error creating virtual source: \(midiClientName) -- \(virtualOutput)")
        }

    
    }
    
    /// Discard all virtual ports
    public func destroyVirtualPorts() {
        if virtualInput != 0 {
            MIDIEndpointDispose(virtualInput)
            virtualInput = 0
        }

        if virtualInput != 0 {
            MIDIEndpointDispose(virtualOutput)
            virtualInput = 0
        }
    }
    
    // MARK: - Input/Output Setup
    
    /// Open a MIDI Input port
    ///
    /// - parameter namedInput: String containing the name of the MIDI Input
    ///
    public func openMIDIIn(namedInput: String = "") {
        //print("Opening MIDI In")
        var result = OSStatus(noErr)
        
        let sourceCount = MIDIGetNumberOfSources()
        //print("SourceCount: \(sourceCount)")
        for i in 0 ..< sourceCount {
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
        for i in 0 ..< sourceCount {
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
        //print("Opening MIDI Out")
        var result = OSStatus(noErr)
        
        let outputCount = MIDIGetNumberOfDestinations()
        //print("Number of MIDI Out ports = \(outputCount)")
        var foundDest = false
        result = MIDIOutputPortCreate(midiClient, midiOutName, &midiOutPort)
        
        if result == OSStatus(noErr) {
            print("created midi out port")
        } else {
            print("error creating midi out port : \(result)")
        }
        
        for i in 0 ..< outputCount {
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
        let outputCount = MIDIGetNumberOfDestinations()
        print("MIDI Destinations:")
        for i in 0 ..< outputCount {
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
        
        var packet: UnsafeMutablePointer<MIDIPacket> = nil
        packet = MIDIPacketListInit(packetListPtr)
        packet = MIDIPacketListAdd(packetListPtr, 1024, packet, 0, data.count, data)
        for _ in 0 ..< midiEndpoints.count {
            result = MIDISend(midiOutPort, midiEndpoints[0], packetListPtr)
            if result == OSStatus(noErr) {
                //print("sent midi")
            } else {
                print("error sending midi : \(result)")
            }
        }

        if virtualOutput != 0 {
            MIDIReceived(virtualOutput, packetListPtr)
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
