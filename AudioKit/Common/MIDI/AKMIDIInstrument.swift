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
    /// - Parameters:
    ///   - midiClient: A refernce to the midi client
    ///   - name: Name to connect with
    ///
    public func enableMIDI(midiClient: MIDIClientRef, name: String) {
        var result: OSStatus
        result = MIDIDestinationCreateWithBlock(midiClient, name, &midiIn, MyMIDIReadBlock)
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
    public func receivedMIDINoteOn(noteNumber: MIDINoteNumber,
                                   velocity: MIDIVelocity,
                                   channel: Int) {
        if velocity > 0 {
            start(noteNumber: noteNumber, velocity: velocity, channel: channel)
        } else {
            stop(noteNumber: noteNumber, channel: channel)
        }
    }
    
    // MARK: - MIDI Note Start/Stop

    /// Start a note
    ///
    /// - Parameters:
    ///   - noteNumber: Note number to play
    ///   - velocity:   Velocity at which to play the note (0 - 127)
    ///   - channel:    Channel on which to play the note
    ///
    public func start(noteNumber noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: Int) {
        internalInstrument!.play(noteNumber: noteNumber, velocity: velocity)
    }

    /// Stop a note
    ///
    /// - Parameters:
    ///   - noteNumber: Note number to stop
    ///   - channel:    Channel on which to stop the note
    ///
    public func stop(noteNumber noteNumber: MIDINoteNumber, channel: Int) {
        internalInstrument!.stop(noteNumber: noteNumber)
    }
    
    // MARK: - Private functions
    
    // Send MIDI data to the audio unit
    func handleMIDI(data1 data1: UInt32, data2: UInt32, data3: UInt32) {
        let status = data1 >> 4
        let channel = data1 & 0xF
        if(Int(status) == AKMIDIStatus.NoteOn.rawValue && data3 > 0) {
            start(noteNumber: MIDINoteNumber(data2), velocity: MIDIVelocity(data3), channel: Int(channel))
        } else if Int(status) == AKMIDIStatus.NoteOn.rawValue && data3 == 0 {
            stop(noteNumber: MIDINoteNumber(data2), channel: Int(channel))
        }
    }

    private func MyMIDIReadBlock(
        packetList: UnsafePointer<MIDIPacketList>,
        srcConnRefCon: UnsafeMutablePointer<Void>) -> Void {
            let packetCount = Int(packetList.memory.numPackets)
            let packet = packetList.memory.packet as MIDIPacket
            var packetPointer: UnsafeMutablePointer<MIDIPacket> = UnsafeMutablePointer.alloc(1)
            packetPointer.initialize(packet)
            for _ in 0 ..< packetCount {
                let event = AKMIDIEvent(packet: packetPointer.memory)
                //the next line is unique for midiInstruments - otherwise this function is the same as AKMIDI
                handleMIDI(data1: UInt32(event.internalData[0]),
                           data2: UInt32(event.internalData[1]),
                           data3: UInt32(event.internalData[2]))
                packetPointer = MIDIPacketNext(packetPointer)
            }
    }
}
