// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

// MARK: - Internal Audio Unit

/// Common AudioUnit for all the STK Instruments
public class STKAudioUnit: AudioUnitBase {
    
    /// Trigger the physical model
    /// - Parameters:
    ///   - type: Type of physical model to create
    ///   - amplitude: How hard to shake or velocity
    public func trigger(type: AUValue, amplitude: AUValue) {
        
        if let midiBlock = scheduleMIDIEventBlock {
            let event = MIDIEvent(noteOn: MIDINoteNumber(type),
                                  velocity: MIDIVelocity(amplitude * 127.0),
                                  channel: 0)
            event.data.withUnsafeBufferPointer { ptr in
                guard let ptr = ptr.baseAddress else { return }
                midiBlock(AUEventSampleTimeImmediate, 0, event.data.count, ptr)
            }
        }
    }
    
    /// Trigger a midi note
    /// - Parameters:
    ///   - note: MIDI Note Number
    ///   - velocity: MIDI Velocity
    public func trigger(note: MIDINoteNumber, velocity: MIDIVelocity) {
        if let midiBlock = scheduleMIDIEventBlock {
            let event = MIDIEvent(noteOn: note, velocity: velocity, channel: 0)
            event.data.withUnsafeBufferPointer { ptr in
                guard let ptr = ptr.baseAddress else { return }
                midiBlock(AUEventSampleTimeImmediate, 0, event.data.count, ptr)
            }
        }

    }
}
