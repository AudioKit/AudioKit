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
/// Be sure to enableMIDI if you want to receive messages
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
    /// - Parameters:
    ///   - midiClient: A refernce to the MIDI client
    ///   - name: Name to connect with
    ///
    public func enableMIDI(_ midiClient: MIDIClientRef, name: String) {
        CheckError(MIDIDestinationCreateWithBlock(midiClient, name, &midiIn, MyMIDIReadBlock))
    }

    // MARK: - Handling MIDI Data

    // Send MIDI data to the audio unit
    func handleMIDI(data1: UInt32, data2: UInt32, data3: UInt32) {
        let status = data1 >> 4
        let channel = data1 & 0xF

        if Int(status) == AKMIDIStatus.noteOn.rawValue && data3 > 0 {
            
            play(noteNumber: MIDINoteNumber(data2),
                 velocity: MIDIVelocity(data3),
                 channel: MIDIChannel(channel))
            
        } else if Int(status) == AKMIDIStatus.noteOn.rawValue && data3 == 0 {
            
            stop(noteNumber: MIDINoteNumber(data2), channel: MIDIChannel(channel))
            
        } else if Int(status) == AKMIDIStatus.controllerChange.rawValue {
            
            midiCC(Int(data2), value: Int(data3), channel: MIDIChannel(channel))
            
        }
    }

    /// Handle MIDI commands that come in externally
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note number
    ///   - velocity:   MIDI velocity
    ///   - channel:    MIDI channel
    ///
    public func receivedMIDINoteOn(noteNumber: MIDINoteNumber,
                                              velocity: MIDIVelocity,
                                              channel: MIDIChannel) {
        if velocity > 0 {
            play(noteNumber: noteNumber, velocity: velocity, channel: channel)
        } else {
            stop(noteNumber: noteNumber, channel: channel)
        }
    }

    /// Handle MIDI CC that come in externally
    ///
    /// - Parameters:
    ///   - cc: MIDI cc number
    ///   - value: MIDI cc value
    ///   - channel: MIDI cc channel
    ///
    public func midiCC(_ cc: Int, value: Int, channel: MIDIChannel) {
        samplerUnit.sendController(UInt8(cc),
                                   withValue: UInt8(value),
                                   onChannel: UInt8(channel))
    }

    // MARK: - MIDI Note Start/Stop

    /// Start a note
    public override func play(noteNumber: MIDINoteNumber,
                                         velocity: MIDIVelocity,
                                         channel: MIDIChannel) {
        samplerUnit.startNote(UInt8(noteNumber),
                              withVelocity: UInt8(velocity),
                              onChannel: UInt8(channel))
    }

    /// Stop a note
    public override func stop(noteNumber: MIDINoteNumber, channel: MIDIChannel) {
        samplerUnit.stopNote(UInt8(noteNumber), onChannel: UInt8(channel))
    }

    private func MyMIDIReadBlock(
        _ packetList: UnsafePointer<MIDIPacketList>,
        srcConnRefCon: UnsafeMutablePointer<Void>?) -> Void {

        let packetCount = Int(packetList.pointee.numPackets)
        let packet = packetList.pointee.packet as MIDIPacket
        var packetPointer: UnsafeMutablePointer<MIDIPacket> = UnsafeMutablePointer.allocate(capacity: 1)
        packetPointer.initialize(to: packet)

        for _ in 0 ..< packetCount {
            let event = AKMIDIEvent(packet: packetPointer.pointee)
            //the next line is unique for midiInstruments - otherwise this function is the same as AKMIDI
            handleMIDI(data1: UInt32(event.internalData[0]),
                       data2: UInt32(event.internalData[1]),
                       data3: UInt32(event.internalData[2]))
            packetPointer = MIDIPacketNext(packetPointer)
        }
    }
}
