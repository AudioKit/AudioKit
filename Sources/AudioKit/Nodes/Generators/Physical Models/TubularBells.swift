// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

/// STK Tubuluar Bells
///
public class TubularBells: NodeBase {

    /// Initialize the STK Tubular Bells model
    public init() {
        super.init(avAudioNode: AVAudioNode())
        avAudioNode = instantiate(instrument: "tbel")
    }

    /// Trigger the sound with a set of parameters
    ///
    /// - Parameters:
    ///   - note: MIDI note number
    ///   - velocity: Amplitude or volume expressed as a MIDI Velocity 0-127
    ///
    public func trigger(note: MIDINoteNumber, velocity: MIDIVelocity = 127) {
        start()
        (avAudioNode.auAudioUnit as? AudioUnitBase)?.trigger(note: note, velocity: velocity)
    }
}
