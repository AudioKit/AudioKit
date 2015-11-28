//
//  AKMidi.swift
//  AudioKit
//
//  Created by Jeff Cooper on 11/5/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import CoreMIDI

//// MIDI input and output handler
public class AKMidi: AKOperation {
    
    /// MIDI Client Reference
    public var midiClient = MIDIClientRef()
    
    /// Array of MIDI In ports
    public var midiInPorts: [MIDIPortRef] = []
    
    /// MIDI Client Name
    var midiClientName: CFString = "Midi Client"
    
    /// MIDI In Port Name
    var midiInName: CFString = "Midi In Port"
    
    /// MIDI End Point
    public var midiEndpoint:MIDIEndpointRef{
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
    public override init() {
        super.init()
        print("MIDI Enabled")
        #if os(iOS)
            MIDINetworkSession.defaultSession().enabled = true
            MIDINetworkSession.defaultSession().connectionPolicy =
                MIDINetworkConnectionPolicy.Anyone
        #endif
    }
    
    /// Open a MIDI In port
    public func openMidiIn(namedInput: String = "") {
        print("Opening Midi In")
        var result = OSStatus(noErr)
        result = MIDIClientCreateWithBlock(midiClientName, &midiClient, MyMIDINotifyBlock)
        if result == OSStatus(noErr) {
            print("created client")
        } else {
            print("error creating client : \(result)")
        }
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
            }//end if no name provided, or input matches provided name
        }//end foreach source
    }
    
    /// Open a MIDI Out Port
    public func openMidiOut(namedOutput: String = ""){
        print("Opening Midi Out")
        var result = OSStatus(noErr)
        if midiClient == 0 {
            result = MIDIClientCreateWithBlock(midiClientName, &midiClient, MyMIDINotifyBlock)
            if result == OSStatus(noErr) {
                print("created client")
            } else {
                print("error creating client : \(result)")
            }
        }
        
        let numOutputs = MIDIGetNumberOfDestinations()
        print("Number of MIDI Out ports = \(numOutputs)")
        
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
            print("Destination at \(endpointNameStr)")
            if namedOutput.isEmpty || namedOutput == endpointNameStr {
                midiEndpoints.append(MIDIGetDestination(i))
            }//end if match or no name set
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
        }//for each midiEndpoint
        
        packetListPtr.destroy()
        packetListPtr.dealloc(1)//necessary? wish i could do this without the alloc above
    }//end sendMessage
    
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

/*
static void AKMIDIReadProc(const MIDIPacketList *pktlist, void *refCon, void *connRefCon)
{
AKMidi *m = (__bridge AKMidi *)refCon;

@autoreleasepool {
MIDIPacket *packet = (MIDIPacket *)pktlist->packet;
for (uint i = 0; i < pktlist->numPackets; i++) {
NSArray<AKMidiEvent *> *events = [AKMidiEvent midiEventsFromPacket:packet];

for (AKMidiEvent *event in events) {
if (event.command == AKMidiCommandClock)
continue;
if (m.forwardEvents) {
[m sendEvent:event];
}
[event postNotification];
}
packet = MIDIPacketNext(packet);
}
}
}
*/
