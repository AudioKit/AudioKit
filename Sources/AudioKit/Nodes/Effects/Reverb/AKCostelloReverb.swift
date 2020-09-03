// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// 8 delay line stereo FDN reverb, with feedback matrix based upon physical
/// modeling scattering junction of 8 lossless waveguides of equal
/// characteristic impedance.
///
public class AKCostelloReverb: AKNode, AKComponent, AKToggleable, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "rvsc")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    public static let feedbackDef = AKNodeParameterDef(
        identifier: "feedback",
        name: "Feedback",
        address: akGetParameterAddress("AKCostelloReverbParameterFeedback"),
        range: 0.0 ... 1.0,
        unit: .generic,
        flags: .default)

    /// Feedback level in the range 0 to 1. 0.6 is good small 'live' room sound, 0.8 a small hall, and 0.9 a large hall.
    /// A setting of exactly 1 means infinite length, while higher values will make the opcode unstable.
    @Parameter public var feedback: AUValue

    public static let cutoffFrequencyDef = AKNodeParameterDef(
        identifier: "cutoffFrequency",
        name: "Cutoff Frequency",
        address: akGetParameterAddress("AKCostelloReverbParameterCutoffFrequency"),
        range: 12.0 ... 20_000.0,
        unit: .hertz,
        flags: .default)

    /// Low-pass cutoff frequency.
    @Parameter public var cutoffFrequency: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKCostelloReverb.feedbackDef,
             AKCostelloReverb.cutoffFrequencyDef]
        }

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKCostelloReverbDSP")
        }
    }

    // MARK: - Initialization

    /// Initialize this reverb node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - feedback: Feedback level in the range 0 to 1.
    ///     0.6 gives a good small 'live' room sound, 0.8 a small hall, and 0.9 a large hall.
    ///     A setting of exactly 1 means infinite length, while higher values will make the opcode unstable.
    ///   - cutoffFrequency: Low-pass cutoff frequency.
    ///
    public init(
        _ input: AKNode? = nil,
        feedback: AUValue = 0.6,
        cutoffFrequency: AUValue = 4_000.0
        ) {
        super.init(avAudioNode: AVAudioNode())
        self.feedback = feedback
        self.cutoffFrequency = cutoffFrequency
        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)
        }

        if let input = input {
            connections.append(input)
        }
    }
}
