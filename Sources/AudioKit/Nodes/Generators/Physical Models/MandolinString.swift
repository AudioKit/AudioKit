// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

#if !os(tvOS)

/// STK Mandolin
///
public class MandolinString: Node, AudioUnitContainer, Toggleable {

    public static let ComponentDescription = AudioComponentDescription(instrument: "mand")

    public typealias AudioUnitType = InternalAU

    public private(set) var internalAU: AudioUnitType?

    public class InternalAU: AudioUnitBase {

        public override func createDSP() -> DSPRef {
            return akCreateDSP("MandolinStringDSP")
        }

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

    /// Initialize the STK Mandolin model
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
