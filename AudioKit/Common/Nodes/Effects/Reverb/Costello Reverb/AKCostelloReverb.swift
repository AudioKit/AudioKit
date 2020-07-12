// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// 8 delay line stereo FDN reverb, with feedback matrix based upon physical
/// modeling scattering junction of 8 lossless waveguides of equal
/// characteristic impedance.
///
open class AKCostelloReverb: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "rvsc")

    public typealias AKAudioUnitType = AKCostelloReverbAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Feedback level in the range 0 to 1. 0.6 is good small 'live' room sound, 0.8 a small hall, and 0.9 a large hall.
    /// A setting of exactly 1 means infinite length, while higher values will make the opcode unstable.
    @Parameter public var feedback: AUValue

    /// Low-pass cutoff frequency.
    @Parameter public var cutoffFrequency: AUValue

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

            input?.connect(to: self)
        }
    }
}
