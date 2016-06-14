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
    public var callbacks = [AKMIDICallback]()
    
    /// Initializethe callback instrument
    ///
    /// - parameter callback: Initial callback
    ///
    public init(callback: AKMIDICallback) {
        // Dummy Instrument
        super.init(instrument: AKPolyphonicInstrument(voice: AKVoice(), voiceCount: 0))
        let midi = AKMIDI()
        self.enableMIDI(midi.client, name: "callback midi in")
        callbacks.append(callback)
    }
    
    private func triggerCallbacks(_ status: AKMIDIStatus, note: MIDINoteNumber, velocity: MIDIVelocity) {
        for callback in callbacks {
            callback(status, note, velocity)
        }
    }
    
    /// Will trigger in response to any noteOn Message
    ///
    /// - parameter note:     MIDI Note being started
    /// - parameter velocity: MIDI Velocity (0-127)
    /// - parameter channel:  MIDI Channel
    ///
    override public func startNote(_ note: Int, withVelocity velocity: Int, onChannel channel: Int) {
        triggerCallbacks(.noteOn, note: note, velocity: velocity)
    }

    /// Will trigger in response to any noteOff Message
    ///
    /// - parameter note:     MIDI Note being stopped
    /// - parameter velocity: MIDI Velocity (0-127)
    /// - parameter channel:  MIDI Channel
    ///
    override public func stopNote(_ note: Int, onChannel channel: Int) {
        triggerCallbacks(.noteOff, note: note, velocity: 0)
    }
}
