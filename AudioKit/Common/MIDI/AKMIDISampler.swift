//
//  AKMIDISampler.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation
import CoreAudio

/// MIDI receiving Sampler
///
/// Be sure to enableMIDI if you want to receive messages
///
open class AKMIDISampler: AKAppleSampler {
    // MARK: - Properties

    /// MIDI Input
    open var midiIn = MIDIEndpointRef()

    /// Name of the instrument
    open var name = "MIDI Sampler"

    /// Initialize the MIDI Sampler
    ///
    /// - Parameter midiOutputName: Name of the instrument's MIDI output
    ///
    public init(midiOutputName: String? = nil) {
        super.init()
        enableMIDI(name: midiOutputName ?? name)
        hideVirtualMIDIPort()
    }

    /// Enable MIDI input from a given MIDI client
    /// This is not in the init function because it must be called AFTER you start AudioKit
    ///
    /// - Parameters:
    ///   - midiClient: A reference to the MIDI client
    ///   - name: Name to connect with
    ///
    open func enableMIDI(_ midiClient: MIDIClientRef = AudioKit.midi.client,
                         name: String = "MIDI Sampler") {
        CheckError(MIDIDestinationCreateWithBlock(midiClient, name as CFString, &midiIn) { packetList, _ in
            for e in packetList.pointee {
                let event = AKMIDIEvent(packet: e)
                do {
                    try self.handle(event: event)
                } catch let exception {
                    AKLog("Exception handling MIDI event: \(exception)")
                }
            }
        })
    }

    private func handle(event: AKMIDIEvent) throws {
        try self.handleMIDI(data1: event.data[0],
                            data2: event.data[1],
                            data3: event.data[2])
    }

    // MARK: - Handling MIDI Data

    // Send MIDI data to the audio unit
    func handleMIDI(data1: MIDIByte, data2: MIDIByte, data3: MIDIByte) throws {
        if let status = AKMIDIStatus(byte: data1) {
            let channel = status.channel
            if status.type == .noteOn && data3 > 0 {
                try play(noteNumber: data2,
                         velocity: data3,
                         channel: channel)
            } else if status.type == .noteOn && data3 == 0 {
                try stop(noteNumber: data2, channel: channel)
            } else if status.type == .controllerChange {
                midiCC(data2, value: data3, channel: channel)
            }
        }
    }

    /// Handle MIDI commands that come in externally
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note number
    ///   - velocity:   MIDI velocity
    ///   - channel:    MIDI channel
    ///
    open func receivedMIDINoteOn(noteNumber: MIDINoteNumber,
                                 velocity: MIDIVelocity,
                                 channel: MIDIChannel) throws {
        if velocity > 0 {
            try play(noteNumber: noteNumber, velocity: velocity, channel: channel)
        } else {
            try stop(noteNumber: noteNumber, channel: channel)
        }
    }

    /// Handle MIDI CC that come in externally
    ///
    /// - Parameters:
    ///   - controller: MIDI CC number
    ///   - value: MIDI CC value
    ///   - channel: MIDI CC channel
    ///
    open func midiCC(_ controller: MIDIByte, value: MIDIByte, channel: MIDIChannel) {
        samplerUnit.sendController(controller, withValue: value, onChannel: channel)
    }

    // MARK: - MIDI Note Start/Stop

    /// Start a note or trigger a sample
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI note number
    ///   - velocity: MIDI velocity
    ///   - channel: MIDI channel
    ///
    /// NB: when using an audio file, noteNumber 60 will play back the file at normal
    /// speed, 72 will play back at double speed (1 octave higher), 48 will play back at
    /// half speed (1 octave lower) and so on
    open override func play(noteNumber: MIDINoteNumber,
                            velocity: MIDIVelocity,
                            channel: MIDIChannel) throws {
        try AKTry {
            self.samplerUnit.startNote(noteNumber, withVelocity: velocity, onChannel: channel)
        }
    }

    /// Stop a note
    open override func stop(noteNumber: MIDINoteNumber, channel: MIDIChannel) throws {
        try AKTry {
            self.samplerUnit.stopNote(noteNumber, onChannel: channel)
        }
    }

    /// Discard all virtual ports
    open func destroyEndpoint() {
        if midiIn != 0 {
            MIDIEndpointDispose(midiIn)
            midiIn = 0
        }
    }

    func showVirtualMIDIPort() {
        MIDIObjectSetIntegerProperty(midiIn, kMIDIPropertyPrivate, 0)
    }
    func hideVirtualMIDIPort() {
        MIDIObjectSetIntegerProperty(midiIn, kMIDIPropertyPrivate, 1)
    }
}
