// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Shane's Chorus
///
public class Chorus: Node, AudioUnitContainer, Tappable, Toggleable {

    /// Unique four-letter identifier "chrs"
    public static let ComponentDescription = AudioComponentDescription(effect: "chrs")

    /// Internal type of audio unit for this node
    public typealias AudioUnitType = InternalAU

    /// Internal audio unit
    public private(set) var internalAU: AudioUnitType?

    // MARK: - Parameters

    /// Specification details for frequency
    public static let frequencyDef = NodeParameterDef(
        identifier: "frequency",
        name: "Frequency (Hz)",
        address: ModulatedDelayParameter.frequency.rawValue,
        range: kChorus_MinFrequency ... kChorus_MaxFrequency,
        unit: .hertz,
        flags: .default)

    /// Modulation Frequency (Hz)
    @Parameter public var frequency: AUValue

    /// Specification details for depth
    public static let depthDef = NodeParameterDef(
        identifier: "depth",
        name: "Depth 0-1",
        address: ModulatedDelayParameter.depth.rawValue,
        range: kChorus_MinDepth ... kChorus_MaxDepth,
        unit: .generic,
        flags: .default)

    /// Modulation Depth (fraction)
    @Parameter public var depth: AUValue

    /// Specification details for feedback
    public static let feedbackDef = NodeParameterDef(
        identifier: "feedback",
        name: "Feedback 0-1",
        address: ModulatedDelayParameter.feedback.rawValue,
        range: kChorus_MinFeedback ... kChorus_MaxFeedback,
        unit: .generic,
        flags: .default)

    /// Feedback (fraction)
    @Parameter public var feedback: AUValue

    /// Specification details for dry wet mix
    public static let dryWetMixDef = NodeParameterDef(
        identifier: "dryWetMix",
        name: "Dry Wet Mix 0-1",
        address: ModulatedDelayParameter.dryWetMix.rawValue,
        range: kChorus_MinDryWetMix ... kChorus_MaxDryWetMix,
        unit: .generic,
        flags: .default)

    /// Dry Wet Mix (fraction)
    @Parameter public var dryWetMix: AUValue

    // MARK: - Audio Unit

    /// Internal audio unit for Chorus
    public class InternalAU: AudioUnitBase {
        /// Get an array of the parameter definitions
        /// - Returns: Array of parameter definitions
        public override func getParameterDefs() -> [NodeParameterDef] {
            return [Chorus.frequencyDef,
                    Chorus.depthDef,
                    Chorus.feedbackDef,
                    Chorus.dryWetMixDef]
        }

        /// Create the DSP Refence for this node
        /// - Returns: DSP Reference
        public override func createDSP() -> DSPRef {
            return akChorusCreateDSP()
        }
    }

    // MARK: - Initialization

    /// Initialize this chorus node
    ///
    /// - Parameters:
    ///   - input: Node whose output will be processed
    ///   - frequency: modulation frequency Hz
    ///   - depth: depth of modulation (fraction)
    ///   - feedback: feedback fraction
    ///   - dryWetMix: fraction of wet signal in mix
    ///
    public init(
        _ input: Node,
        frequency: AUValue = kChorus_DefaultFrequency,
        depth: AUValue = kChorus_DefaultDepth,
        feedback: AUValue = kChorus_DefaultFeedback,
        dryWetMix: AUValue = kChorus_DefaultDryWetMix
    ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AudioUnitType

            self.frequency = frequency
            self.depth = depth
            self.feedback = feedback
            self.dryWetMix = dryWetMix
        }

        connections.append(input)
    }
}
