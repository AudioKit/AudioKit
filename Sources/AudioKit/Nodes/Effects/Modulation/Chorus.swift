// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Shane's Chorus
///
public class Chorus: Node {

    let input: Node
    
    /// Connected nodes
    public var connections: [Node] { [input] }

    /// Underlying AVAudioNode
    public var avAudioNode = instantiate(effect: "chrs")

    // MARK: - Parameters
    
    /// Specification details for frequency
    public static let frequencyDef = NodeParameterDef(
        identifier: "frequency",
        name: "Frequency (Hz)",
        address: ModulatedDelayParameter.frequency.rawValue,
        defaultValue: kChorus_DefaultFrequency,
        range: kChorus_MinFrequency ... kChorus_MaxFrequency,
        unit: .hertz)

    /// Modulation Frequency (Hz)
    @Parameter(frequencyDef) public var frequency: AUValue

    /// Specification details for depth
    public static let depthDef = NodeParameterDef(
        identifier: "depth",
        name: "Depth 0-1",
        address: ModulatedDelayParameter.depth.rawValue,
        defaultValue: kChorus_DefaultDepth,
        range: kChorus_MinDepth ... kChorus_MaxDepth,
        unit: .generic)

    /// Modulation Depth (fraction)
    @Parameter(depthDef) public var depth: AUValue

    /// Specification details for feedback
    public static let feedbackDef = NodeParameterDef(
        identifier: "feedback",
        name: "Feedback 0-1",
        address: ModulatedDelayParameter.feedback.rawValue,
        defaultValue: kChorus_DefaultFeedback,
        range: kChorus_MinFeedback ... kChorus_MaxFeedback,
        unit: .generic)

    /// Feedback (fraction)
    @Parameter(feedbackDef) public var feedback: AUValue

    /// Specification details for dry wet mix
    public static let dryWetMixDef = NodeParameterDef(
        identifier: "dryWetMix",
        name: "Dry Wet Mix 0-1",
        address: ModulatedDelayParameter.dryWetMix.rawValue,
        defaultValue: kChorus_DefaultDryWetMix,
        range: kChorus_MinDryWetMix ... kChorus_MaxDryWetMix,
        unit: .generic)

    /// Dry Wet Mix (fraction)
    @Parameter(dryWetMixDef) public var dryWetMix: AUValue

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
        frequency: AUValue = frequencyDef.defaultValue,
        depth: AUValue = depthDef.defaultValue,
        feedback: AUValue = feedbackDef.defaultValue,
        dryWetMix: AUValue = dryWetMixDef.defaultValue
    ) {
        self.input = input
        
        setupParameters()

        self.frequency = frequency
        self.depth = depth
        self.feedback = feedback
        self.dryWetMix = dryWetMix
    }
}
