//
//  AKCallbackInstrument.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

/// Function type for MIDI callbacks
public typealias AKMIDICallback = (AKMIDIStatus, MIDINoteNumber, MIDIVelocity) -> Void

/// MIDI Instrument that triggers functions on MIDI note on/off commands
public class AKCallbackInstrument: AKMIDIInstrument {

    // MARK: Properties

    /// All callbacks that will get triggered by MIDI events
    public var callback: AKMIDICallback?

    /// Initialize the callback instrument
    ///
    /// - parameter callback: Initial callback
    ///
    public init(callback: AKMIDICallback) {
        super.init()
        let midi = AKMIDI()
        self.enableMIDI(midi.client, name: "callback midi in")
        self.callback = callback
        avAudioNode = AVAudioMixerNode()
        AudioKit.engine.attachNode(self.avAudioNode)
    }

    private func triggerCallbacks(status: AKMIDIStatus,
                                  noteNumber: MIDINoteNumber,
                                  velocity: MIDIVelocity) {
        if callback != nil {
            callback!(status, noteNumber, velocity)
        }
    }

    /// Will trigger in response to any noteOn Message
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number being started
    ///   - velocity:   MIDI Velocity (0-127)
    ///   - channel:    MIDI Channel
    ///
    override public func start(noteNumber noteNumber: MIDINoteNumber,
                                          velocity: MIDIVelocity,
                                          channel: MIDIChannel) {
        triggerCallbacks(.NoteOn, noteNumber: noteNumber, velocity: velocity)
    }

    /// Will trigger in response to any noteOff Message
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number being stopped
    ///   - velocity:   MIDI Velocity (0-127)
    ///   - channel:    MIDI Channel
    ///
    override public func stop(noteNumber noteNumber: MIDINoteNumber, channel: MIDIChannel) {
        triggerCallbacks(.NoteOff, noteNumber: noteNumber, velocity: 0)
    }
}