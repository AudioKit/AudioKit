// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

#if !os(tvOS)

/// STK TubularBells
///
public class TubularBells: Node, AudioUnitContainer, Toggleable {

    /// Unique four-letter identifier "tbel"
    public static let ComponentDescription = AudioComponentDescription(instrument: "tbel")

    /// Internal type of audio unit for this node
    public typealias AudioUnitType = STKAudioUnit

    /// Internal audio unit type
    public private(set) var internalAU: AudioUnitType?

    // MARK: - Initialization

    /// Initialize the STK Tubular Bells model
    ///
    /// - Parameters:
    ///   - note: MIDI note number
    ///   - velocity: Amplitude or volume expressed as a MIDI Velocity 0-127
    ///
    public init() {
        super.init(avAudioNode: AVAudioNode())
        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AudioUnitType
        }
    }

    /// Trigger the sound with a set of parameters
    ///
    /// - Parameters:
    ///   - note: MIDI note number
    ///   - velocity: Amplitude or volume expressed as a MIDI Velocity 0-127
    ///
    public func trigger(note: MIDINoteNumber, velocity: MIDIVelocity = 127) {
        internalAU?.start()
        internalAU?.trigger(note: note, velocity: velocity)
    }

}

#endif
