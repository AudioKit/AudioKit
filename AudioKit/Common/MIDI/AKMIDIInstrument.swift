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
    
    open var mpeActiveNotes: [(note: MIDINoteNumber, channel: MIDIChannel)] = []
    
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
        guard event.data.count > 2 else {
            return
        }
        self.handleMIDI(data1: event.data[0],
                        data2: event.data[1],
                        data3: event.data[2])
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
        mpeActiveNotes.append((noteNumber, channel))
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
    open func receivedMIDINoteOff(noteNumber: MIDINoteNumber,
                                  velocity: MIDIVelocity,
                                  channel: MIDIChannel) {
        stop(noteNumber: noteNumber, channel: channel)
        mpeActiveNotes.removeAll(where: { $0 == (noteNumber, channel) })
    }
    
    /// Receive a generic controller value
    ///
    /// - Parameters:
    ///   - controller: MIDI Controller Number
    ///   - value:      Value of this controller
    ///   - channel:    MIDI Channel (1-16)
    ///
    @objc open func receivedMIDIController(_ controller: MIDIByte,
                                           value: MIDIByte,
                                           channel: MIDIChannel) {
        // Override in subclass
    }
    
    /// Receive single note based aftertouch event
    ///
    /// - Parameters:
    ///   - noteNumber: Note number of touched note
    ///   - pressure:   Pressure applied to the note (0-127)
    ///   - channel:    MIDI Channel (1-16)
    ///
    @objc open func receivedMIDIAftertouch(noteNumber: MIDINoteNumber,
                                           pressure: MIDIByte,
                                           channel: MIDIChannel) {
        // Override in subclass
    }
    
    /// Receive global aftertouch
    ///
    /// - Parameters:
    ///   - pressure: Pressure applied (0-127)
    ///   - channel:  MIDI Channel (1-16)
    ///
    @objc open func receivedMIDIAfterTouch(_ pressure: MIDIByte,
                                           channel: MIDIChannel) {
        // Override in subclass
    }
    
    /// Receive pitch wheel value
    ///
    /// - Parameters:
    ///   - pitchWheelValue: MIDI Pitch Wheel Value (0-16383)
    ///   - channel:         MIDI Channel (1-16)
    ///
    @objc open func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord,
                                           channel: MIDIChannel) {
        // Override in subclass
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
        play(noteNumber: noteNumber, velocity: velocity, channel: channel)
    }
    
    /// Stop a note
    ///
    /// - Parameters:
    ///   - noteNumber: Note number to stop
    ///   - channel:    Channel on which to stop the note
    ///
    @objc open func stop(noteNumber: MIDINoteNumber,
                         channel: MIDIChannel) {
        // Override in subclass
    }
    
    // MARK: - Private functions
    
    // Send MIDI data to the audio unit
    func handleMIDI(data1: MIDIByte, data2: MIDIByte, data3: MIDIByte) {
        if let status = AKMIDIStatus(byte: data1), let statusType = status.type {

            let channel = status.channel

            switch statusType {
            case .noteOn:
                if data3 > 0 {
                    start(noteNumber: data2, velocity: data3, channel: channel)
                } else {
                    stop(noteNumber: data2, channel: channel)
                }
            case .noteOff:
                stop(noteNumber: data2, channel: channel)
            case .polyphonicAftertouch:
                receivedMIDIAftertouch(noteNumber: data2, pressure: data3, channel: channel)
            case .channelAftertouch:
                receivedMIDIAfterTouch(data2, channel: channel)
            case .controllerChange:
                receivedMIDIController(data2, value: data3, channel: channel)
            case .programChange:
                receivedMIDIProgramChange(data2, channel: channel)
            case .pitchWheel:
                receivedMIDIPitchWheel(MIDIWord(byte1: data2, byte2: data3), channel: channel)
            }
        }
    }
    
    func showVirtualMIDIPort() {
        MIDIObjectSetIntegerProperty(midiIn, kMIDIPropertyPrivate, 0)
    }
    
    func hideVirtualMIDIPort() {
        MIDIObjectSetIntegerProperty(midiIn, kMIDIPropertyPrivate, 1)
    }
}
