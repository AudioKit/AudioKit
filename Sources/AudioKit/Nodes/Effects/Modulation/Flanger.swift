// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Stereo Flanger
///
public class Flanger: Node, AudioUnitContainer, Toggleable {

    /// Unique four-letter identifier "flgr"
    public static let ComponentDescription = AudioComponentDescription(effect: "flgr")

    /// Internal type of audio unit for this node
    public typealias AudioUnitType = AudioUnitBase

    /// Internal audio unit
    public private(set) var internalAU: AudioUnitType?

    // MARK: - Parameters

    /// Specification for the frequency
    public static let frequencyDef = NodeParameterDef(
        identifier: "frequency",
        name: "Frequency (Hz)",
        address: ModulatedDelayParameter.frequency.rawValue,
        defaultValue: kFlanger_DefaultFrequency,
        range: kFlanger_MinFrequency ... kFlanger_MaxFrequency,
        unit: .hertz,
        flags: .default)

    /// Modulation Frequency (Hz)
    @Parameter(frequencyDef) public var frequency: AUValue

    /// Specification for the depth
    public static let depthDef = NodeParameterDef(
        identifier: "depth",
        name: "Depth 0-1",
        address: ModulatedDelayParameter.depth.rawValue,
        defaultValue: kFlanger_DefaultDepth,
        range: kFlanger_MinDepth ... kFlanger_MaxDepth,
        unit: .generic,
        flags: .default)

    /// Modulation Depth (fraction)
    @Parameter(depthDef) public var depth: AUValue

    /// Specification for the feedback
    public static let feedbackDef = NodeParameterDef(
        identifier: "feedback",
        name: "Feedback 0-1",
        address: ModulatedDelayParameter.feedback.rawValue,
        defaultValue: kFlanger_DefaultFeedback,
        range: kFlanger_MinFeedback ... kFlanger_MaxFeedback,
        unit: .generic,
        flags: .default)

    /// Feedback (fraction)
    @Parameter(feedbackDef) public var feedback: AUValue

    /// Specification for the dry wet mix
    public static let dryWetMixDef = NodeParameterDef(
        identifier: "dryWetMix",
        name: "Dry Wet Mix 0-1",
        address: ModulatedDelayParameter.dryWetMix.rawValue,
        defaultValue: kFlanger_DefaultDryWetMix,
        range: kFlanger_MinDryWetMix ... kFlanger_MaxDryWetMix,
        unit: .generic,
        flags: .default)

    /// Dry Wet Mix (fraction)
    @Parameter(dryWetMixDef) public var dryWetMix: AUValue

    // MARK: - Initialization

    /// Initialize this flanger node
    ///
    /// - Parameters:
    ///   - input: Node whose output will be processed
    ///   - frequency: modulation frequency Hz
    ///   - depth: depth of modulation (fraction)
    ///   - feedback: feedback fraction
    ///   - dryWetMix: fraction of wet signal in mix  - traditionally 50%, avoid changing this value
    ///
    public init(
        _ input: Node,
        frequency: AUValue = frequencyDef.defaultValue,
        depth: AUValue = depthDef.defaultValue,
        feedback: AUValue = feedbackDef.defaultValue,
        dryWetMix: AUValue = dryWetMixDef.defaultValue
    ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
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
