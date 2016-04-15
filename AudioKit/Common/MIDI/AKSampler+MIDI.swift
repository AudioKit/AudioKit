//
//  AKSampler+MIDI.swift
//  AudioKit For iOS
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AVFoundation
import CoreAudio

/// MIDI receiving Sampler
///
/// be sure to enableMIDI if you want to receive messages
///
public class AKMIDISampler: AKSampler {
    // MARK: - Properties
    
    /// MIDI Input
    public var midiIn = MIDIEndpointRef()
    
    /// Name of the instrument
    public var name = "AKMIDISampler"
    
    /// Enable MIDI input from a given MIDI client
    /// This is not in the init function because it must be called AFTER you start audiokit
    ///
    /// - parameter midiClient: A refernce to the midi client
    /// - parameter name: Name to connect with
    ///
    public func enableMIDI(midiClient: MIDIClientRef, name: String) {
        var result: OSStatus
        result = MIDIDestinationCreateWithBlock(midiClient, name, &midiIn, MyMIDIReadBlock)
        CheckError(result)
    }
    
    // MARK: - Handling MIDI Data
    
    // Send MIDI data to the audio unit
    func handleMIDI(data1: UInt32, data2: UInt32, data3: UInt32) {
        let status = data1 >> 4
        let channel = data1 & 0xF
        
        if(Int(status) == AKMIDIStatus.NoteOn.rawValue && data3 > 0) {
            startNote(Int(data2), withVelocity: Int(data3), onChannel: Int(channel))
        } else if Int(status) == AKMIDIStatus.NoteOn.rawValue && data3 == 0 {
            stopNote(Int(data2), onChannel: Int(channel))
        } else if Int(status) == AKMIDIStatus.ControllerChange.rawValue {
            midiCC(Int(data2), value: Int(data3), channel: Int(channel))
        }
    }
    
    /// Handle MIDI commands that come in externally
    ///
    /// - parameter note: MIDI Note number
    /// - parameter velocity: MIDI velocity
    /// - parameter channel: MIDI channel
    ///
    public func midiNoteOn(note: Int, velocity: Int, channel: Int) {
        if velocity > 0 {
            startNote(note, withVelocity: velocity, onChannel: channel)
        } else {
            stopNote(note, onChannel: channel)
        }
    }
    /// Handle MIDI CC that come in externally
    ///
    /// - parameter cc: MIDI cc number
    /// - parameter value: MIDI cc value
    /// - parameter channel: MIDI cc channel
    ///
    public func midiCC(cc: Int, value: Int, channel: Int) {
        print("cc \(cc) val \(value) chan \(channel)")
        samplerUnit.sendController(UInt8(cc), withValue: UInt8(value), onChannel: UInt8(channel))
    }
    // MARK: - MIDI Note Start/Stop
    
    /// Start a note
    public func startNote(note: Int, withVelocity velocity: Int, onChannel channel: Int) {
        samplerUnit.startNote(UInt8(note), withVelocity: UInt8(velocity), onChannel: UInt8(channel))
    }
    
    /// Stop a note
    public func stopNote(note: Int, onChannel channel: Int) {
        samplerUnit.stopNote(UInt8(note), onChannel: UInt8(channel))
    }
    
    private func MyMIDIReadBlock(
        packetList: UnsafePointer<MIDIPacketList>,
        srcConnRefCon: UnsafeMutablePointer<Void>) -> Void {
        let packetCount = Int(packetList.memory.numPackets)
        let packet = packetList.memory.packet as MIDIPacket
        var packetPtr: UnsafeMutablePointer<MIDIPacket> = UnsafeMutablePointer.alloc(1)
        packetPtr.initialize(packet)
        for _ in 0 ..< packetCount {
            let event = AKMIDIEvent(packet: packetPtr.memory)
            //the next line is unique for midiInstruments - otherwise this function is the same as AKMIDI
            handleMIDI(UInt32(event.internalData[0]), data2: UInt32(event.internalData[1]), data3: UInt32(event.internalData[2]))
            packetPtr = MIDIPacketNext(packetPtr)
        }
    }
}
