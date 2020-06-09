// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// This filter reiterates input with an echo density determined by
/// loopDuration. The attenuation rate is independent and is determined by
/// reverbDuration, the reverberation duration (defined as the time in seconds
/// for a signal to decay to 1/1000, or 60dB down from its original amplitude).
/// Output from a comb filter will appear only after loopDuration seconds.
///
open class AKCombFilterReverb: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "comb")

    public typealias AKAudioUnitType = AKCombFilterReverbAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Lower and upper bounds for Reverb Duration
    public static let reverbDurationRange: ClosedRange<AUValue> = 0.0 ... 10.0

    /// Initial value for Reverb Duration
    public static let defaultReverbDuration: AUValue = 1.0

    /// Initial value for Loop Duration
    public static let defaultLoopDuration: AUValue = 0.1

    /// The time in seconds for a signal to decay to 1/1000, or 60dB from its original amplitude. (aka RT-60).
    public let reverbDuration = AKNodeParameter(identifier: "reverbDuration")

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - reverbDuration: The time in seconds for a signal to decay to 1/1000,
    ///     or 60dB from its original amplitude. (aka RT-60).
    ///   - loopDuration: The loop time of the filter, in seconds.
    ///     This can also be thought of as the delay time.
    ///     Determines frequency response curve, loopDuration * sr/2 peaks spaced evenly between 0 and sr/2.
    ///
    public init(
        _ input: AKNode? = nil,
        reverbDuration: AUValue = defaultReverbDuration,
        loopDuration: AUValue = defaultLoopDuration
        ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.reverbDuration.associate(with: self.internalAU, value: reverbDuration)

            input?.connect(to: self)
        }
    }
}
