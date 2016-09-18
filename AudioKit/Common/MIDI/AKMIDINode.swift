//
//  AKMIDINode.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AVFoundation
import CoreAudio

/// A version of AKInstrument specifically targeted to instruments that
/// should be triggerable via MIDI or sequenced with the sequencer.
open class AKMIDINode: AKNode, AKMIDIListener {

    // MARK: - Properties

    /// MIDI Input
    open var midiIn = MIDIEndpointRef()

    /// Name of the instrument
    open var name = "AKMIDINode"

    internal var internalNode: AKPolyphonicNode

    // MARK: - Initialization

    /// Initialize the MIDI node
    ///
    /// - parameter node: A polyphonic node that will be triggered via MIDI
    ///
    public init(node: AKPolyphonicNode) {
        internalNode = node
        super.init()
        avAudioNode = internalNode.avAudioNode
    }


    /// Enable MIDI input from a given MIDI client
    /// This is not in the init function because it must be called AFTER you start audiokit
    ///
    /// - Parameters:
    ///   - midiClient: A refernce to the midi client
    ///   - name: Name to connect with
    ///
    open func enableMIDI(_ midiClient: MIDIClientRef, name: String) {
        var result: OSStatus
        
        let readBlock: MIDIReadBlock = { packetList, srcConnRefCon in
            let packetCount = Int(packetList.pointee.numPackets)
            let packet = packetList.pointee.packet as MIDIPacket
            var packetPointer: UnsafeMutablePointer<MIDIPacket> = UnsafeMutablePointer.allocate(capacity: 1)
            packetPointer.initialize(to: packet)
            
            for _ in 0 ..< packetCount {
                let event = AKMIDIEvent(packet: packetPointer.pointee)
                
                self.handleMIDI(data1: UInt32(event.internalData[0]),
                                data2: UInt32(event.internalData[1]),
                                data3: UInt32(event.internalData[2]))
                packetPointer = MIDIPacketNext(packetPointer)
            }
        }
                
        result = MIDIDestinationCreateWithBlock(midiClient, name as CFString, &midiIn, readBlock)
        CheckError(result)
    }

    // MARK: - Handling MIDI Data

    // Send MIDI data to the audio unit
    func handleMIDI(data1: UInt32, data2: UInt32, data3: UInt32) {
        let status = Int(data1 >> 4)
        let noteNumber = Int(data2)
        let velocity = Int(data3)

        if status == AKMIDIStatus.noteOn.rawValue && velocity > 0 {
            internalNode.play(noteNumber: noteNumber, velocity: velocity)
        } else if status == AKMIDIStatus.noteOn.rawValue && velocity == 0 {
            internalNode.stop(noteNumber: noteNumber)
        } else if status == AKMIDIStatus.noteOff.rawValue {
            internalNode.stop(noteNumber: noteNumber)
        }
    }

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
            internalNode.play(noteNumber: noteNumber, velocity: velocity)
        } else {
            internalNode.stop(noteNumber: noteNumber)
        }
    }
}
