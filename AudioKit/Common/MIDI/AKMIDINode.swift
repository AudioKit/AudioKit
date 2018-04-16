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
                self.handleMIDI(data1: MIDIByte(event.internalData[0]),
                                data2: MIDIByte(event.internalData[1]),
                                data3: MIDIByte(event.internalData[2]))

            }
        })
    }

    // MARK: - Handling MIDI Data

    // Send MIDI data to the audio unit
    func handleMIDI(data1: MIDIByte, data2: MIDIByte, data3: MIDIByte) {
        let status = Int(data1 >> 4)
        let noteNumber = MIDINoteNumber(data2)
        let velocity = MIDIVelocity(data3)

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
