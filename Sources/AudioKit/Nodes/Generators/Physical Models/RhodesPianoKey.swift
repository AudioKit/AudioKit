// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

#if !os(tvOS)

/// STK RhodesPiano
///
public class RhodesPianoKey: Node, AudioUnitContainer, Tappable, Toggleable {

    /// Unique four-letter identifier "rhds"
    public static let ComponentDescription = AudioComponentDescription(instrument: "rhds")

    /// Internal type of audio unit for this node
    public typealias AudioUnitType = InternalAU

    /// Internal audio unit
    public private(set) var internalAU: AudioUnitType?

    /// Internal audio unit for Rhodes piano key
    public class InternalAU: AudioUnitBase {

        /// Create Rhodes Piano Key DSP
        /// - Returns: DSP Reference
        public override func createDSP() -> DSPRef {
            return akCreateDSP("RhodesPianoKeyDSP")
        }

        /// Trigger a rhoes piano key note
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

    // MARK: - Initialization

    /// Initialize the STK Rhdoes Piano model
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
