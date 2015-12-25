//
//  AKMidiInstrument.swift
//  AudioKit For iOS
//
//  Created by Jeff Cooper on 12/17/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

/// MIDI Instrument Controller
public class AKMidiInstrumentControl {
    
    /// MIDI Input
    public var midiIn = MIDIEndpointRef()
    
    /// Output Node
    public var audioUnit:AudioUnit?
    
    /// Name
    public var name:String?
    
    /// Initialize the MIDI Instrument Controller
    public init(){
        audioUnit = AudioUnit()
        name = "MidiInstrument"
    }
    
    /// Initialize the MIDI Instrument Controller with an audio unit
    public convenience init(audioUnit: AudioUnit) {
        self.init()
        self.audioUnit = audioUnit
        name = "MidiInstrument"
    }
    
    /// Initialize the MIDI Instrument Controller with an audio unit and a midi client
    public convenience init(audioUnit:AudioUnit, client: MIDIClientRef, name: String) {
        self.init()
        self.audioUnit = audioUnit
        self.name = name
        enableMidi(client, name: name)
    }
    
    /// Enable MIDI input from a given MIDI client
    public func enableMidi(midiClient: MIDIClientRef, name: String) {
        var result:OSStatus
        result = MIDIDestinationCreateWithBlock(midiClient, name, &midiIn, MyMIDIReadBlock)
        CheckError(result)
    }
    
    /// Send MIDI data to the audio unit
    func handleMidi(data1: UInt32, data2: UInt32, data3: UInt32) {
        MusicDeviceMIDIEvent(self.audioUnit!, data1, data2, data3, 0)
    }
    
    private func MyMIDIReadBlock(
        packetList: UnsafePointer<MIDIPacketList>,
        srcConnRefCon: UnsafeMutablePointer<Void>) -> Void {
            let numPackets = Int(packetList.memory.numPackets)
            let packet = packetList.memory.packet as MIDIPacket
            var packetPtr: UnsafeMutablePointer<MIDIPacket> = UnsafeMutablePointer.alloc(1)
            packetPtr.initialize(packet)
            for var i = 0; i < numPackets; ++i {
                let event = AKMidiEvent(packet: packetPtr.memory)
                //the next line is unique for midiInstruments - otherwise this function is the same as AKMidi
                handleMidi(UInt32(event.internalData[0]), data2: UInt32(event.internalData[1]), data3: UInt32(event.internalData[2]))
                packetPtr = MIDIPacketNext(packetPtr)
            }
    }
}