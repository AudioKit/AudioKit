//
//  AKMIDIInstrument.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
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
    open var name = "AudioKit MIDI Instrument"

    /// Initialize the MIDI Instrument
    ///
    /// - Parameter midiInputName: Name of the instrument's MIDI input
    ///
    public init(midiInputName: String? = nil) {
        super.init()
        name = midiInputName ?? name
        enableMIDI(name: midiInputName ?? name)
        hideVirtualMIDIPort()
    }

    /// Enable MIDI input from a given MIDI client
    ///
    /// - Parameters:
    ///   - midiClient: A reference to the midi client
    ///   - name: Name to connect with
    ///
    open func enableMIDI(_ midiClient: MIDIClientRef = AudioKit.midi.client,
                         name: String = "AudioKit MIDI Instrument") {
        CheckError(MIDIDestinationCreateWithBlock(midiClient, name as CFString, &midiIn) { packetList, _ in
            for e in packetList.pointee {
                let event = AKMIDIEvent(packet: e)
                self.handle(event: event)
            }
        })
    }

    private func handle(event: AKMIDIEvent) {
        self.handleMIDI(data1: MIDIByte(event.internalData[0]),
                        data2: MIDIByte(event.internalData[1]),
                        data3: MIDIByte(event.internalData[2]))
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
    @objc open func start(noteNumber: MIDINoteNumber,
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
    @objc open func stop(noteNumber: MIDINoteNumber, channel: MIDIChannel) {
        // OVerride in subclass
    }

    // MARK: - Private functions

    // Send MIDI data to the audio unit
    func handleMIDI(data1: MIDIByte, data2: MIDIByte, data3: MIDIByte) {
        let status = data1 >> 4
        let channel = data1 & 0xF
        if Int(status) == AKMIDIStatus.noteOn.rawValue && data3 > 0 {
            start(noteNumber: MIDINoteNumber(data2),
                  velocity: MIDIVelocity(data3),
                  channel: MIDIChannel(channel))
        } else if Int(status) == AKMIDIStatus.noteOn.rawValue && data3 == 0 {
            stop(noteNumber: MIDINoteNumber(data2), channel: MIDIChannel(channel))
        }
    }

    func showVirtualMIDIPort() {
        MIDIObjectSetIntegerProperty(midiIn, kMIDIPropertyPrivate, 0)
    }
    func hideVirtualMIDIPort() {
        MIDIObjectSetIntegerProperty(midiIn, kMIDIPropertyPrivate, 1)
    }
}
