// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Clips a signal to a predefined limit, in a "soft" manner, using one of three
/// methods.
///
public class DiodeClipper: Node, AudioUnitContainer, Tappable, Toggleable {

    /// Unique four-letter identifier "dclp"
    public static let ComponentDescription = AudioComponentDescription(effect: "dclp")

    /// Internal type of audio unit for this node
    public typealias AudioUnitType = InternalAU

    /// Internal audio unit
    public private(set) var internalAU: AudioUnitType?

    // MARK: - Parameters

    /// Specification for the cutoff frequency
    public static let cutoffFrequencyDef = NodeParameterDef(
        identifier: "cutoffFrequency",
        name: "Cutoff Frequency (Hz)",
        address: akGetParameterAddress("DiodeClipperParameterCutoff"),
        range: 12.0 ... 20_000.0,
        unit: .hertz,
        flags: .default)

    /// Filter cutoff frequency.
    @Parameter public var cutoffFrequency: AUValue

    /// Specification for the gain
    public static let gainDef = NodeParameterDef(
        identifier: "gain",
        name: "Gain",
        address: akGetParameterAddress("DiodeClipperParameterGaindB"),
        range: 0.0 ... 40.0,
        unit: .decibels,
        flags: .default)

    /// Determines the amount of gain applied to the signal before waveshaping. A value of 1 gives slight distortion.
    @Parameter public var gain: AUValue

    // MARK: - Audio Unit

    /// Internal audio unit for diode clipper
    public class InternalAU: AudioUnitBase {
        /// Get an array of the parameter definitions
        /// - Returns: Array of parameter definitions
        public override func getParameterDefs() -> [NodeParameterDef] {
            [DiodeClipper.cutoffFrequencyDef,
             DiodeClipper.gainDef]
        }

        /// Create diode clipper DSP
        /// - Returns: DSP Reference
        public override func createDSP() -> DSPRef {
            akCreateDSP("DiodeClipperDSP")
        }
    }

    // MARK: - Initialization

    /// Initialize this clipper node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - cutoffFrequency: Cutoff frequency
    ///   - gain: Gain in dB
    ///
    public init(_ input: Node,
                cutoffFrequency: AUValue = 10000.0,
                gain: AUValue = 20.0
    ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AudioUnitType

            self.cutoffFrequency = cutoffFrequency
            self.gain = gain
        }

        connections.append(input)
    }
}
