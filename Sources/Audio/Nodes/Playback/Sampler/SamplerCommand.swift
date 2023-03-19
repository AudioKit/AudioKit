// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

enum SamplerCommand {
    /// Play a sample immediately
    case playSample(UnsafeMutablePointer<SampleHolder>)

    /// Assign a sample to a midi note number.
    case assignSample(UnsafeMutablePointer<SampleHolder>?, UInt8)

    /// Stop all samples associated with a MIDI Note
    case stop(UInt8)

    /// Stop all playback
    case panic
}
