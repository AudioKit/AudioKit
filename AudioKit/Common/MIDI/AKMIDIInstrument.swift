//
//  AKMIDIInstrument.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AVFoundation
import CoreAudio

/// A version of AKInstrument specifically targeted to instruments that 
/// should be triggerable via MIDI or sequenced with the sequencer.
public class AKMIDIInstrument: AKNode, AKMIDIListener {

    // MARK: - Properties
    
    /// MIDI Input
    public var midiIn = MIDIEndpointRef()
    
    /// Name of the instrument
    public var name = "AKMIDIInstrument"
    
    internal var internalInstrument: AKPolyphonicInstrument?
    
    // MARK: - Initialization
    
    /// Initialize the MIDI instrument
    ///
    /// - parameter instrument: A polyphonic instrument that will be triggered via MIDI
    ///
    public init(instrument: AKPolyphonicInstrument) {
        internalInstrument = instrument
        super.init()
        avAudioNode = (internalInstrument?.avAudioNode)!
    }
    
    /// Enable MIDI input from a given MIDI client
    /// This is not in the init function because it must be called AFTER you start audiokit
    ///
    /// - parameter midiClient: A refernce to the midi client
    /// - parameter name: Name to connect with
    ///
    public func enableMIDI(_ midiClient: MIDIClientRef, name: String) {
        var result: OSStatus
        result = MIDIDestinationCreateWithBlock(midiClient, name, &midiIn, MyMIDIReadBlock)
        CheckError(result)
    }
    
    // MARK: - Handling MIDI Data
    
    // Send MIDI data to the audio unit
    func handleMIDI(_ data1: UInt32, data2: UInt32, data3: UInt32) {
        let status = data1 >> 4
        let channel = data1 & 0xF
        if(Int(status) == AKMIDIStatus.noteOn.rawValue && data3 > 0) {
            startNote(Int(data2), withVelocity: Int(data3), onChannel: Int(channel))
        } else if Int(status) == AKMIDIStatus.noteOn.rawValue && data3 == 0 {
            stopNote(Int(data2), onChannel: Int(channel))
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
    // MARK: - MIDI Note Start/Stop
    
    /// Start a note
    public func startNote(_ note: Int, withVelocity velocity: Int, onChannel channel: Int) {
        internalInstrument!.playNote(note, velocity: velocity)
    }
    
    /// Stop a note
    public func stopNote(_ note: Int, onChannel channel: Int) {
        internalInstrument!.stopNote(note)
    }
    
    private func MyMIDIReadBlock(
        _ packetList: UnsafePointer<MIDIPacketList>,
        srcConnRefCon: UnsafeMutablePointer<Void>) -> Void {
            let packetCount = Int(packetList.pointee.numPackets)
            let packet = packetList.pointee.packet as MIDIPacket
            var packetPointer: UnsafeMutablePointer<MIDIPacket> = UnsafeMutablePointer(allocatingCapacity: 1)
            packetPointer.initialize(with: packet)
            for _ in 0 ..< packetCount {
                let event = AKMIDIEvent(packet: packetPointer.pointee)
                //the next line is unique for midiInstruments - otherwise this function is the same as AKMIDI
                handleMIDI(UInt32(event.internalData[0]), data2: UInt32(event.internalData[1]), data3: UInt32(event.internalData[2]))
                packetPointer = MIDIPacketNext(packetPointer)
            }
    }
}
