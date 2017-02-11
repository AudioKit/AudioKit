//
//  AKCallbackInstrument.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Function type for MIDI callbacks
public typealias AKMIDICallback = (AKMIDIStatus, MIDINoteNumber, MIDIVelocity) -> Void

/// MIDI Instrument that triggers functions on MIDI note on/off commands
open class AKCallbackInstrument: AKMIDIInstrument {

    // MARK: Properties

    /// All callbacks that will get triggered by MIDI events
    open var callback: AKMIDICallback?

    /// Initialize the callback instrument
    ///
    /// - parameter callback: Initial callback
    ///
    public init(callback: AKMIDICallback? = nil) {
        super.init()
        let midi = AKMIDI()
        self.enableMIDI(midi.client, name: "callback midi in")
        self.callback = callback
        avAudioNode = AVAudioMixerNode()
        AudioKit.engine.attach(self.avAudioNode)
    }

    fileprivate func triggerCallbacks(_ status: AKMIDIStatus,
                                  noteNumber: MIDINoteNumber,
                                  velocity: MIDIVelocity) {
        _ = callback.map { $0(status, noteNumber, velocity) }
    }

    /// Will trigger in response to any noteOn Message
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number being started
    ///   - velocity:   MIDI Velocity (0-127)
    ///   - channel:    MIDI Channel
    ///
    override open func start(noteNumber: MIDINoteNumber,
                                          velocity: MIDIVelocity,
                                          channel: MIDIChannel) {
        triggerCallbacks(.noteOn, noteNumber: noteNumber, velocity: velocity)
    }

    /// Will trigger in response to any noteOff Message
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number being stopped
    ///   - velocity:   MIDI Velocity (0-127)
    ///   - channel:    MIDI Channel
    ///
    override open func stop(noteNumber: MIDINoteNumber, channel: MIDIChannel) {
        triggerCallbacks(.noteOff, noteNumber: noteNumber, velocity: 0)
    }
}
