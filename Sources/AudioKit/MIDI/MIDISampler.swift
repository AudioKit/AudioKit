// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)

import AVFoundation
import CoreAudio
import os.log

// TODO: add other deprecation warnings

/// MIDI receiving Sampler
///
/// Be sure to enableMIDI if you want to receive messages
///
open class MIDISampler: AppleSampler {
    // MARK: - Handling MIDI Data
    
    // Send MIDI data to the audio unit
    func handleMIDI(data1: MIDIByte, data2: MIDIByte, data3: MIDIByte) throws {
        if let status = MIDIStatus(byte: data1) {
            let channel = status.channel
            if status.type == .noteOn && data3 > 0 {
                play(noteNumber: data2,
                     velocity: data3,
                     channel: channel)
            } else if status.type == .noteOn && data3 == 0 {
                stop(noteNumber: data2, channel: channel)
            } else if status.type == .controllerChange {
                midiCC(data2, value: data3, channel: channel)
            }
        }
    }
    
    /// Handle MIDI CC that come in externally
    ///
    /// - Parameters:
    ///   - controller: MIDI CC number
    ///   - value: MIDI CC value
    ///   - channel: MIDI CC channel
    ///
    @available(*, deprecated, message: "midiCC(controller:, value:, channel:) is depreated. Use receivedMIDIController(controller, value: channel:) instead.")
    public func midiCC(_ controller: MIDIByte, value: MIDIByte, channel: MIDIChannel) {
        samplerUnit.sendController(controller, withValue: value, onChannel: channel)
    }
}

#endif
