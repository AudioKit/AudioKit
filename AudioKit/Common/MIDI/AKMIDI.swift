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
    private var client = MIDIClientRef()
    
    /// Array of MIDI In ports
    private var inputPorts = [MIDIPortRef]()

    /// Virtual MIDI Input destination
    private var virtualInput = MIDIPortRef()

    /// MIDI Client Name
    private var clientName: CFString = "MIDI Client"
    
    /// MIDI In Port Name
    private var inputPortName: CFString = "MIDI In Port"
    
    /// MIDI End Point
    private var endpoint: MIDIEndpointRef {
        return endpoints[0]
    }
    
    /// Array of MIDI Out ports
    private var outputPorts = [MIDIPortRef]()
    
    /// MIDI Out Port Reference
    private var outputPort = MIDIPortRef()

    /// Virtual MIDI output
    private var virtualOutput = MIDIPortRef()

    
    /// Array of MIDI Endpoints
    private var endpoints = [MIDIEndpointRef]()
    
    /// MIDI Out Port Name
    private var outputPortName: CFString = "MIDI Out Port"
    
    /// Array of all listeners
    private var listeners = [AKMIDIListener]()
    
    /// Array of input names
    public var inputNames: [String] {
        var nameArray = [String]()
        let sourceCount = MIDIGetNumberOfSources()
        
        for i in 0 ..< sourceCount {
            let source = MIDIGetSource(i)
            var inputName: Unmanaged<CFString>?
            inputName = nil
            MIDIObjectGetStringProperty(source, kMIDIPropertyName, &inputName)
            let inputNameStr = (inputName?.takeRetainedValue())! as String
            nameArray.append(inputNameStr)
        }
        return nameArray
    }
    
    /// Array of destination names
    public var destinationNames: [String] {
        var nameArray = [String]()
        let outputCount = MIDIGetNumberOfDestinations()
        for i in 0 ..< outputCount {
            let destination = MIDIGetDestination(i)
            var endpointName: Unmanaged<CFString>?
            endpointName = nil
            MIDIObjectGetStringProperty(destination, kMIDIPropertyName, &endpointName)
            let endpointNameStr = (endpointName?.takeRetainedValue())! as String
            nameArray.append(endpointNameStr)
        }
        return nameArray
    }
    

    // MARK: - Initialization

    /// Initialize the AKMIDI system
    public init() {

        #if os(iOS)
            MIDINetworkSession.defaultSession().enabled = true
            MIDINetworkSession.defaultSession().connectionPolicy =
                MIDINetworkConnectionPolicy.Anyone
        #endif
        var result = OSStatus(noErr)
        if client == 0 {
            result = MIDIClientCreateWithBlock(clientName, &client, MyMIDINotifyBlock)
            if result == OSStatus(noErr) {
                print("created midi client")
            } else {
                print("error creating midi client : \(result)")
            }
        }
    }
    
    /// Create set of virtual MIDI ports
    public func createVirtualPorts(uniqueId: Int32 = 2000000) {

        destroyVirtualPorts()
        
        var result = OSStatus(noErr)
        result = MIDIDestinationCreateWithBlock(client, clientName, &virtualInput, MyMIDIReadBlock)
        
        if result == OSStatus(noErr) {
            print("Created virt dest: \(clientName)")
            MIDIObjectSetIntegerProperty(virtualInput, kMIDIPropertyUniqueID, uniqueId)
        } else {
            print("Error creatervirt dest: \(clientName) -- \(virtualInput)")
        }
        
        
        result = MIDISourceCreate(client, clientName, &virtualOutput)
        if result == OSStatus(noErr) {
            print("Created virt source: \(clientName)")
            MIDIObjectSetIntegerProperty(virtualInput, kMIDIPropertyUniqueID, uniqueId + 1)
        } else {
            print("Error creating virtual source: \(clientName) -- \(virtualOutput)")
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
        var result = OSStatus(noErr)
        
        let sourceCount = MIDIGetNumberOfSources()

        for i in 0 ..< sourceCount {
            let src = MIDIGetSource(i)
            var tempName: Unmanaged<CFString>? = nil

            MIDIObjectGetStringProperty(src, kMIDIPropertyName, &tempName)
            let inputNameStr = (tempName?.takeRetainedValue())! as String
            if namedInput.isEmpty || namedInput == inputNameStr {

                inputPorts.append(MIDIPortRef())
                var port = inputPorts.last!
                result = MIDIInputPortCreateWithBlock(
                    client, inputPortName, &port, MyMIDIReadBlock)
                if result == OSStatus(noErr) {
                    print("created midiInPort at \(inputNameStr)")
                } else {
                    print("error creating midiInPort : \(result)")
                }
                MIDIPortConnectSource(port, src, nil)
            }
        }
    }
    
    /// Open a MIDI Output Port
    ///
    /// - parameter namedOutput: String containing the name of the MIDI Input
    ///
    public func openMIDIOut(namedOutput: String = "") {

        var result = OSStatus(noErr)
        
        let outputCount = MIDIGetNumberOfDestinations()
        var foundDest = false
        result = MIDIOutputPortCreate(client, outputPortName, &outputPort)
        
        if result == OSStatus(noErr) {
            print("created midi out port")
        } else {
            print("error creating midi out port : \(result)")
        }
        
        for i in 0 ..< outputCount {
            let src = MIDIGetDestination(i)
            var endpointName: Unmanaged<CFString>? = nil

            MIDIObjectGetStringProperty(src, kMIDIPropertyName, &endpointName)
            let endpointNameStr = (endpointName?.takeRetainedValue())! as String
            if namedOutput.isEmpty || namedOutput == endpointNameStr {
                print("Found destination at \(endpointNameStr)")
                endpoints.append(MIDIGetDestination(i))
                foundDest = true
            }
        }
        if !foundDest {
            print("no midi destination found named \"\(namedOutput)\"")
        }
    }
    
    // MARK: - Receiving MIDI
    
    /// Add a listener to the listeners
    public func addListener(listener: AKMIDIListener) {
        listeners.append(listener)
    }
    
    private func handleMidiMessage(event: AKMIDIEvent) {
        for listener in listeners {
            let type = event.status
            switch type {
            case AKMIDIStatus.ControllerChange:
                listener.midiController(Int(event.internalData[1]),
                                        value: Int(event.internalData[2]),
                                        channel: Int(event.channel))
            case AKMIDIStatus.ChannelAftertouch:
                listener.midiAfterTouch(Int(event.internalData[1]),
                                        channel: Int(event.channel))
            case AKMIDIStatus.NoteOn:
                listener.midiNoteOn(Int(event.internalData[1]),
                                    velocity: Int(event.internalData[2]),
                                    channel: Int(event.channel))
            case AKMIDIStatus.NoteOff:
                listener.midiNoteOff(Int(event.internalData[1]),
                                     velocity: Int(event.internalData[2]),
                                     channel: Int(event.channel))
            case AKMIDIStatus.PitchWheel:
                listener.midiPitchWheel(Int(event.data),
                                        channel: Int(event.channel))
            case AKMIDIStatus.PolyphonicAftertouch:
                listener.midiAftertouchOnNote(Int(event.internalData[1]),
                                              pressure: Int(event.internalData[2]),
                                              channel: Int(event.channel))
            case AKMIDIStatus.ProgramChange:
                listener.midiProgramChange(Int(event.internalData[1]),
                                           channel: Int(event.channel))
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

    // MARK: - Sending MIDI
    
    /// Send Message with data
    public func sendMessage(data: [UInt8]) {
        var result = OSStatus(noErr)
        let packetListPtr: UnsafeMutablePointer<MIDIPacketList> = UnsafeMutablePointer.alloc(1)
        
        var packet: UnsafeMutablePointer<MIDIPacket> = nil
        packet = MIDIPacketListInit(packetListPtr)
        packet = MIDIPacketListAdd(packetListPtr, 1024, packet, 0, data.count, data)
        for _ in 0 ..< endpoints.count {
            result = MIDISend(outputPort, endpoints[0], packetListPtr)
            if result != OSStatus(noErr) {
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
    
    // MARK: - Utility Functions
    
    /// Prints a list of all MIDI Inputs
    public func printMIDIDestinations() {
        for destinationName in destinationNames {
            print("Destination at \(destinationName)")
        }
    }
    
    /// Prints a list of all MIDI Inputs
    public func printMIDIInputs() {
        for inputName in inputNames {
            print("midiIn at \(inputName)")
        }
    }
}
