//
//  AKCallbackInstrument.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

public typealias AKMIDICallback = (AKMIDIStatus, MIDINoteNumber, MIDIVelocity) -> Void

public class AKCallbackInstrument: AKMIDIInstrument {
    
    // MARK: Properties
    
    public var callbacks = [AKMIDICallback]()
    
    public init() {
        // Dummy Instrument
        super.init(instrument: AKPolyphonicInstrument(voice: AKVoice(), voiceCount: 0))
        let midi = AKMIDI()
        self.enableMIDI(midi.client, name: "callback midi in")
    }
    
    private func triggerCallbacks(status: AKMIDIStatus, note: MIDINoteNumber, velocity: MIDIVelocity) {
        for callback in callbacks {
            callback(status, note, velocity)
        }
    }
    
    // Will trig in response to any noteOn Message
    override public func startNote(note: Int, withVelocity velocity: Int, onChannel channel: Int) {
        triggerCallbacks(.NoteOn, note: note, velocity: velocity)
    }
    
    override public func stopNote(note: Int, onChannel channel: Int) {
        triggerCallbacks(.NoteOff, note: note, velocity: 0)
    }
}