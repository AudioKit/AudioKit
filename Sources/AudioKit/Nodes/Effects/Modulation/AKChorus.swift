// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Shane's Chorus
///
public class AKChorus: AKNode, AKToggleable, AKComponent {

    public static let ComponentDescription = AudioComponentDescription(effect: "chrs")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - Parameters

    public static let frequencyDef = AKNodeParameterDef(
        identifier: "frequency",
        name: "Frequency (Hz)",
        address: AKModulatedDelayParameter.frequency.rawValue,
        range: kAKChorus_MinFrequency ... kAKChorus_MaxFrequency,
        unit: .hertz,
        flags: .default)

    /// Modulation Frequency (Hz)
    @Parameter public var frequency: AUValue

    public static let depthDef = AKNodeParameterDef(
        identifier: "depth",
        name: "Depth 0-1",
        address: AKModulatedDelayParameter.depth.rawValue,
        range: kAKChorus_MinDepth ... kAKChorus_MaxDepth,
        unit: .generic,
        flags: .default)

    /// Modulation Depth (fraction)
    @Parameter public var depth: AUValue

    public static let feedbackDef = AKNodeParameterDef(
        identifier: "feedback",
        name: "Feedback 0-1",
        address: AKModulatedDelayParameter.feedback.rawValue,
        range: kAKChorus_MinFeedback ... kAKChorus_MaxFeedback,
        unit: .generic,
        flags: .default)

    /// Feedback (fraction)
    @Parameter public var feedback: AUValue

    public static let dryWetMixDef = AKNodeParameterDef(
        identifier: "dryWetMix",
        name: "Dry Wet Mix 0-1",
        address: AKModulatedDelayParameter.dryWetMix.rawValue,
        range: kAKChorus_MinDryWetMix ... kAKChorus_MaxDryWetMix,
        unit: .generic,
        flags: .default)

    /// Dry Wet Mix (fraction)
    @Parameter public var dryWetMix: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            return [AKChorus.frequencyDef,
                    AKChorus.depthDef,
                    AKChorus.feedbackDef,
                    AKChorus.dryWetMixDef]
        }

        public override func createDSP() -> AKDSPRef {
            return akChorusCreateDSP()
        }
    }

    // MARK: - Initialization

    /// Initialize this chorus node
    ///
    /// - Parameters:
    ///   - input: AKNode whose output will be processed
    ///   - frequency: modulation frequency Hz
    ///   - depth: depth of modulation (fraction)
    ///   - feedback: feedback fraction
    ///   - dryWetMix: fraction of wet signal in mix
    ///
    public init(
        _ input: AKNode,
        frequency: AUValue = kAKChorus_DefaultFrequency,
        depth: AUValue = kAKChorus_DefaultDepth,
        feedback: AUValue = kAKChorus_DefaultFeedback,
        dryWetMix: AUValue = kAKChorus_DefaultDryWetMix
    ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            self.frequency = frequency
            self.depth = depth
            self.feedback = feedback
            self.dryWetMix = dryWetMix
        }

        connections.append(input)
    }
}
