//
//  AKMIDISampler.swift
//  AudioKit
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
    /// This is not in the init function because it must be called AFTER you start AudioKit
    ///
    /// - parameter midiClient: A refernce to the MIDI client
    /// - parameter name: Name to connect with
    ///
    public func enableMIDI(_ midiClient: MIDIClientRef, name: String) {
        var result: OSStatus
        
        let midiReadBlock: MIDIReadBlock = { packetList, srcConnRefCon in
                
            let packetCount = Int(packetList.pointee.numPackets)
            let packet = packetList.pointee.packet as MIDIPacket
            var packetPointer: UnsafeMutablePointer<MIDIPacket> = UnsafeMutablePointer(allocatingCapacity: 1)
            packetPointer.initialize(with: packet)
            
            for _ in 0 ..< packetCount {
                let event = AKMIDIEvent(packet: packetPointer.pointee)
                //the next line is unique for midiInstruments - otherwise this function is the same as AKMIDI
                self.handleMIDI(UInt32(event.internalData[0]), data2: UInt32(event.internalData[1]), data3: UInt32(event.internalData[2]))
                packetPointer = MIDIPacketNext(packetPointer)
            }
        }
        
        result = MIDIDestinationCreateWithBlock(midiClient, name, &midiIn, midiReadBlock)
        CheckError(result)
    }
    
    // MARK: - Handling MIDI Data
    
    // Send MIDI data to the audio unit
    func handleMIDI(_ data1: UInt32, data2: UInt32, data3: UInt32) {
        let status = data1 >> 4
        let channel = data1 & 0xF
        
        if Int(status) == AKMIDIStatus.noteOn.rawValue && data3 > 0 {
            startNote(Int(data2), withVelocity: Int(data3), onChannel: Int(channel))
        } else if Int(status) == AKMIDIStatus.noteOn.rawValue && data3 == 0 {
            stopNote(Int(data2), onChannel: Int(channel))
        } else if Int(status) == AKMIDIStatus.controllerChange.rawValue {
            midiCC(Int(data2), value: Int(data3), channel: Int(channel))
        }
    }
    
    /// Handle MIDI commands that come in externally
    ///
    /// - parameter note: MIDI Note number
    /// - parameter velocity: MIDI velocity
    /// - parameter channel: MIDI channel
    ///
    public func receivedMIDINoteOn(_ note: Int, velocity: Int, channel: Int) {
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
    public func midiCC(_ cc: Int, value: Int, channel: Int) {
        samplerUnit.sendController(UInt8(cc), withValue: UInt8(value), onChannel: UInt8(channel))
    }
    
    // MARK: - MIDI Note Start/Stop
    
    /// Start a note
    public func startNote(_ note: Int, withVelocity velocity: Int, onChannel channel: Int) {
        samplerUnit.startNote(UInt8(note), withVelocity: UInt8(velocity), onChannel: UInt8(channel))
    }
    
    /// Stop a note
    public func stopNote(_ note: Int, onChannel channel: Int) {
        samplerUnit.stopNote(UInt8(note), onChannel: UInt8(channel))
    }
    
}
