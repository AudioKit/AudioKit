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
open class AKMIDIInstrument: AKPolyphonicNode, AKMIDIListener {

    // MARK: - Properties

    /// MIDI Input
    open var midiIn = MIDIEndpointRef()

    /// Name of the instrument
    open var name = "AKMIDIInstrument"

    /// Enable MIDI input from a given MIDI client
    /// This is not in the init function because it must be called AFTER you start audiokit
    ///
    /// - Parameters:
    ///   - midiClient: A refernce to the midi client
    ///   - name: Name to connect with
    ///
    open func enableMIDI(_ midiClient: MIDIClientRef, name: String) {
        var result: OSStatus
        result = MIDIDestinationCreateWithBlock(midiClient, name as CFString, &midiIn, MyMIDIReadBlock as! MIDIReadBlock)
        CheckError(result)
    }

    // MARK: - Handling MIDI Data

    /// Handle MIDI commands that come in externally
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note number
    ///   - velocity:   MIDI velocity
    ///   - channel:    MIDI channel
    ///
    open func receivedMIDINoteOn(_ noteNumber: MIDINoteNumber,
                                   velocity: MIDIVelocity,
                                   channel: MIDIChannel) {
        if velocity > 0 {
            start(noteNumber: noteNumber, velocity: velocity, channel: channel)
        } else {
            stop(noteNumber: noteNumber, channel: channel)
        }
    }
    
    /// Handle MIDI commands that come in externally
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note number
    ///   - velocity:   MIDI velocity
    ///   - channel:    MIDI channel
    ///
    open func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        stop(noteNumber: noteNumber, channel: channel)
    }
    
    // MARK: - MIDI Note Start/Stop

    /// Start a note
    ///
    /// - Parameters:
    ///   - noteNumber: Note number to play
    ///   - velocity:   Velocity at which to play the note (0 - 127)
    ///   - channel:    Channel on which to play the note
    ///
    open func start(noteNumber: MIDINoteNumber,
                                 velocity: MIDIVelocity,
                                 channel: MIDIChannel) {
        play(noteNumber: noteNumber, velocity: velocity)
    }

    /// Stop a note
    ///
    /// - Parameters:
    ///   - noteNumber: Note number to stop
    ///   - channel:    Channel on which to stop the note
    ///
    open func stop(noteNumber: MIDINoteNumber, channel: MIDIChannel) {
        // OVerride in subclass
    }
    
    // MARK: - Private functions
    
    // Send MIDI data to the audio unit
    func handleMIDI(data1: UInt32, data2: UInt32, data3: UInt32) {
        let status = data1 >> 4
        let channel = data1 & 0xF
        if(Int(status) == AKMIDIStatus.noteOn.rawValue && data3 > 0) {
            start(noteNumber: MIDINoteNumber(data2),
                  velocity: MIDIVelocity(data3),
                  channel: MIDIChannel(channel))
        } else if Int(status) == AKMIDIStatus.noteOn.rawValue && data3 == 0 {
            stop(noteNumber: MIDINoteNumber(data2), channel: MIDIChannel(channel))
        }
    }

    fileprivate func MyMIDIReadBlock(
        _ packetList: UnsafePointer<MIDIPacketList>,
        srcConnRefCon: UnsafeMutableRawPointer) -> Void {
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
