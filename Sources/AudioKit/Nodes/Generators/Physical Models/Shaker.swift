// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

#if !os(tvOS)

/// Type of shaker to use
public enum ShakerType: MIDIByte {

    /// Maraca
    case maraca = 0

    /// Cabasa
    case cabasa = 1

    /// Sekere
    case sekere = 2

    /// Tambourine
    case tambourine = 3

    /// Sleigh Bells
    case sleighBells = 4

    /// Bamboo Chimes
    case bambooChimes = 5

    /// Using sand paper
    case sandPaper = 6

    /// Soda Can
    case sodaCan = 7

    /// Sticks falling
    case sticks = 8

    /// Crunching sound
    case crunch = 9

    /// Big rocks hitting each other
    case bigRocks = 10

    /// Little rocks hitting each other
    case littleRocks = 11

    /// NeXT Mug
    case nextMug = 12

    /// A penny rattling around a mug
    case pennyInMug = 13

    /// A nickle rattling around a mug
    case nickleInMug = 14

    /// A dime rattling around a mug
    case dimeInMug = 15

    /// A quarter rattling around a mug
    case quarterInMug = 16

    /// A Franc rattling around a mug
    case francInMug = 17

    /// A Peso rattling around a mug
    case pesoInMug = 18

    /// Guiro
    case guiro = 19

    /// Wrench
    case wrench = 20

    /// Water Droplets
    case waterDrops = 21

    /// Tuned Bamboo Chimes
    case tunedBambooChimes = 22
}

/// STK Shaker
///
public class Shaker: Node, AudioUnitContainer, Tappable, Toggleable {
    /// Four letter unique description "shak"
    public static let ComponentDescription = AudioComponentDescription(instrument: "shak")

    /// Internal type of audio unit for this node
    public typealias AudioUnitType = InternalAU

    /// Internal audio unit
    public private(set) var internalAU: AudioUnitType?

    // MARK: - Parameters

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    // MARK: - Internal Audio Unit

    /// Internal audio unti for shaker
    public class InternalAU: AudioUnitBase {

        /// Create shaker DSP
        /// - Returns: DSP Reference
        public override func createDSP() -> DSPRef {
            return akCreateDSP("ShakerDSP")
        }

        /// Trigger the shaker
        /// - Parameters:
        ///   - type: Type of shaker to create
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
    }

    // MARK: - Initialization

    /// Initialize the STK Shaker model
    public init() {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AudioUnitType
        }
    }

    /// Trigger the sound with an optional set of parameters
    ///
    /// - Parameters:
    ///   - type: various shaker types are supported
    ///   - amplitude: how hard to shake
    public func trigger(type: ShakerType, amplitude: Double = 0.5) {
        internalAU?.start()
        internalAU?.trigger(type: AUValue(type.rawValue), amplitude: AUValue(amplitude))
    }
}

#endif
