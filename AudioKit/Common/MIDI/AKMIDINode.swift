//
//  AKMIDINode.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
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

    private var internalNode: AKPolyphonicNode

    // MARK: - Initialization

    /// Initialize the MIDI node
    ///
    /// - parameter node: A polyphonic node that will be triggered via MIDI
    /// - parameter midiOutputName: Name of the node's MIDI output
    ///
    @objc public init(node: AKPolyphonicNode, midiOutputName: String? = nil) {
        internalNode = node
        super.init()
        avAudioNode = internalNode.avAudioNode
        avAudioUnit = internalNode.avAudioUnit
      enableMIDI(name: midiOutputName ?? "Unnamed")
    }

    /// Enable MIDI input from a given MIDI client
    ///
    /// - Parameters:
    ///   - midiClient: A reference to the midi client
    ///   - name: Name to connect with
    ///
    open func enableMIDI(_ midiClient: MIDIClientRef = AudioKit.midi.client,
                         name: String = "Unnamed") {
        CheckError(MIDIDestinationCreateWithBlock(midiClient, name as CFString, &midiIn) { packetList, _ in
            for e in packetList.pointee {
                let event = AKMIDIEvent(packet: e)
                guard event.data.count > 2 else {
                    return
                }
                self.handleMIDI(data1: event.data[0],
                                data2: event.data[1],
                                data3: event.data[2])

            }
        })
    }

    // MARK: - Handling MIDI Data

    // Send MIDI data to the audio unit
    func handleMIDI(data1: MIDIByte, data2: MIDIByte, data3: MIDIByte) {
        let status = AKMIDIStatus(byte: data1)
        let channel = status?.channel
        let noteNumber = MIDINoteNumber(data2)
        let velocity = MIDIVelocity(data3)

        if status?.type == .noteOn && velocity > 0 {
            internalNode.play(noteNumber: noteNumber, velocity: velocity, channel: channel ?? 0)
        } else if status?.type == .noteOn && velocity == 0 {
            internalNode.stop(noteNumber: noteNumber)
        } else if status?.type == .noteOff {
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
                                 channel: MIDIChannel,
                                 offset: MIDITimeStamp = 0) {
        if velocity > 0 {
            internalNode.play(noteNumber: noteNumber, velocity: velocity, channel: channel)
        } else {
            internalNode.stop(noteNumber: noteNumber)
        }
    }
}
