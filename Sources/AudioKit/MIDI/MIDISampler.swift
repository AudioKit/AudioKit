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
    /// Handle MIDI CC that come in externally
    ///
    /// - Parameters:
    ///   - controller: MIDI CC number
    ///   - value: MIDI CC value
    ///   - channel: MIDI CC channel
    ///
    @available(*, deprecated, message: "midiCC(controller:, value:, channel:) is depreated. Use receivedMIDIController(controller, value: channel:) instead.")
    public func midiCC(_ controller: MIDIByte, value: MIDIByte, channel: MIDIChannel) {
        receivedMIDIController(controller, value: value, channel: channel)
    }
}

#endif
