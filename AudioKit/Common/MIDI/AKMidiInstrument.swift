//
//  AKMidiInstrument.swift
//  AudioKit
//
//  Created by Jeff Cooper on 1/1/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AVFoundation
import CoreAudio

public class AKMidiInstrument: AKPolyphonicInstrument {
    
    /// MIDI Input
    public var midiIn = MIDIEndpointRef()
    
    public var name = "AKMidiInstrument"
    
    public override init(voice: AKVoice, voiceCount: Int) {
        super.init(voice: voice, voiceCount: voiceCount)
    }
    
    /// Enable MIDI input from a given MIDI client
    /// This is not in the init function because it must be called AFTER you start audiokit
    public func enableMidi(midiClient: MIDIClientRef, name: String) {
        var result:OSStatus
        result = MIDIDestinationCreateWithBlock(midiClient, name, &midiIn, MyMIDIReadBlock)
        CheckError(result)
    }
    
    /// Send MIDI data to the audio unit
    func handleMidi(data1: UInt32, data2: UInt32, data3: UInt32) {
        let status = data1 >> 4
        let channel = data1 & 0xF
        if(Int(status) == AKMidiStatus.NoteOn.rawValue && data3 > 0){
            handleNoteOn(Int(data2), withVelocity: Int(data3), onChannel: UInt8(channel))
        }else if(Int(status) == AKMidiStatus.NoteOn.rawValue && data3 == 0){
            handleNoteOff(Int(data2), onChannel: UInt8(channel))
        }
    }
    
    public func handleMidiNotif(notif:NSNotification){
        let note = Int((notif.userInfo?["note"])! as! NSNumber)
        let vel = Int((notif.userInfo?["velocity"])! as! NSNumber)
        let chan = Int((notif.userInfo?["channel"])! as! NSNumber)
        if(notif.name == AKMidiStatus.NoteOn.name() && vel > 0){
            handleNoteOn(note, withVelocity: vel, onChannel: UInt8(chan))
        } else if ((notif.name == AKMidiStatus.NoteOn.name() && vel == 0) || notif.name == AKMidiStatus.NoteOff.name()){
            handleNoteOff(note, onChannel: UInt8(chan))
        }
    }
    
    public func handleNoteOn(note: Int, withVelocity velocity: Int, onChannel channel: UInt8) {
        startNote(note, velocity: velocity)
    }
    
    public func handleNoteOff(note: Int, onChannel channel: UInt8) {
        stopNote(note)
    }
    
    public override func startVoice(voice: Int, note: Int, velocity: Int) {
        /* OVERRIDE ME */
        print("Voice playing is \(voice) - note:\(note) - vel:\(velocity)")
    }
    public override func stopVoice(voice: Int, note: Int) {
        /* OVERRIDE ME */
        //you'll need to cast the voice to its original form
        print("Stopping voice\(voice) - note:\(note)")
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