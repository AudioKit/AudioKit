// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// This filter reiterates the input with an echo density determined by loop
/// time. The attenuation rate is independent and is determined by the
/// reverberation time (defined as the time in seconds for a signal to decay to
/// 1/1000, or 60dB down from its original amplitude).  Output will begin to
/// appear immediately.
///
open class AKFlatFrequencyResponseReverb: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "alps")

    public typealias AKAudioUnitType = AKFlatFrequencyResponseReverbAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Lower and upper bounds for Reverb Duration
    public static let reverbDurationRange: ClosedRange<AUValue> = 0 ... 10

    /// Initial value for Reverb Duration
    public static let defaultReverbDuration: AUValue = 0.5

    /// Initial value for Loop Duration
    public static let defaultLoopDuration: AUValue = 0.1

    /// The duration in seconds for a signal to decay to 1/1000, or 60dB down from its original amplitude.
    public let reverbDuration = AKNodeParameter(identifier: "reverbDuration")

    // MARK: - Initialization

    /// Initialize this reverb node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - reverbDuration: Duration in seconds for signal to decay to 1/1000, or 60dB down from its original amplitude.
    ///   - loopDuration: Loop duration of the filter, in seconds.
    ///     This can also be thought of as the delay time or “echo density” of the reverberation.
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
