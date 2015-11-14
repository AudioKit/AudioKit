//
//  AKMidi.swift
//  AudioKit
//
//  Created by Jeff Cooper on 11/5/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import CoreMIDI

public class AKMidi: AKOperation {
    public var midiClient = MIDIClientRef()
    public var midiInPort = MIDIPortRef()
    public var midiInPorts:[MIDIClientRef] = []
    var midiClientName:CFString = "Midi In Client"
    var midiInName:CFString = "Midi In Port"
    
    func MyMIDINotifyBlock(midiNotification: UnsafePointer<MIDINotification>) {
        let notification = midiNotification.memory
        print("MIDI Notify, messageId= \(notification.messageID.rawValue)")
        
    }
    func MyMIDIReadBlock(packetList: UnsafePointer<MIDIPacketList>, srcConnRefCon: UnsafeMutablePointer<Void>) -> Void {
        
        /*
        //can't yet figure out how to access the port passed via srcConnRefCon
        //maybe having this port is not that necessary though...
        let midiPortPtr = UnsafeMutablePointer<MIDIPortRef>(srcConnRefCon)
        let midiPort = midiPortPtr.memory
        */
        let numPackets = Int(packetList.memory.numPackets)
        let packet = packetList.memory.packet as MIDIPacket
        var packetPtr:UnsafeMutablePointer<MIDIPacket> = UnsafeMutablePointer.alloc(1)
        packetPtr.initialize(packet)
        
        for (var i = 0; i < numPackets; ++i){
            let event = AKMidiEvent(packet: packetPtr.memory)
            event.postNotification()
            packetPtr = MIDIPacketNext(packetPtr)
        }
    }
    
    public override init() {
        super.init()
        print("howdy world, from AKMidi")
        #if os(iOS)
            MIDINetworkSession.defaultSession().enabled = true
            MIDINetworkSession.defaultSession().connectionPolicy = MIDINetworkConnectionPolicy.Anyone
        #endif
    }
    public func openMidiIn(namedInput: String = ""){
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
        for(var i = 0; i < sourceCount; ++i){
            let src = MIDIGetSource(i)
            var inputName : Unmanaged<CFString>?
            inputName = nil
            MIDIObjectGetStringProperty(src, kMIDIPropertyName, &inputName)
            if(namedInput.isEmpty || namedInput == (inputName?.takeRetainedValue())! as String){
                midiInPorts.append(MIDIPortRef())
                result = MIDIInputPortCreateWithBlock(midiClient, midiInName, &midiInPorts[i], MyMIDIReadBlock)
                if result == OSStatus(noErr) {
                    print("created midiInPort")
                } else {
                    print("error creating midiInPort : \(result)")
                }
                print("inputName \(inputName!.takeRetainedValue())")
                MIDIPortConnectSource(midiInPorts[i], src, nil)
            }//end if no name provided, or input matches provided name
        }//end foreach source
    }//end openMidiIn
    
}//end AKMidi class

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