// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Stereo delay-line with stereo (linked dual mono) and ping-pong modes
///
open class AKStereoDelay: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "sdly")

    public typealias AKAudioUnitType = AKStereoDelayAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Lower and upper bounds for Time
    public static let timeRange: ClosedRange<AUValue> = 0.0 ... 2.0

    /// Lower and upper bounds for Feedback
    public static let feedbackRange: ClosedRange<AUValue> = 0.0 ... 1.0

    /// Lower and upper bounds for Dry/wet mix
    public static let dryWetMixRange: ClosedRange<AUValue> = 0.0 ... 1.0

    /// Initial value for Time
    public static let defaultTime: AUValue = 0.0

    /// Initial value for Feedback
    public static let defaultFeedback: AUValue = 0.0

    /// Initial default value for Dry/wet mix
    public static let defaultDryWetMix: AUValue = 0.5

    /// Delay time (in seconds) This value must not exceed the maximum delay time.
    public let time = AKNodeParameter(identifier: "time")

    /// Feedback amount. Should be a value between 0-1.
    public let feedback = AKNodeParameter(identifier: "feedback")

    /// Dry/wet mix. Should be a value between 0-1.
    public let dryWetMix = AKNodeParameter(identifier: "dryWetMix")

    /// Ping-pong mode: true or false (stereo mode)
    public let pingPong = AKNodeParameter(identifier: "pingPong")

    // MARK: - Initialization

    /// Initialize this delay node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - maximumDelayTime: The maximum delay time, in seconds.
    ///   - time: Delay time (in seconds) This value must not exceed the maximum delay time.
    ///   - feedback: Feedback amount. Should be a value between 0-1.
    ///   - dryWetMix: Dry/wet mix. Should be a value between 0-1.
    ///   - pingPong: true for ping-pong mode, false for stereo mode.
    ///
    public init(
        _ input: AKNode? = nil,
        maximumDelayTime: AUValue = AKStereoDelay.timeRange.upperBound,
        time: AUValue = defaultTime,
        feedback: AUValue = defaultFeedback,
        dryWetMix: AUValue = defaultDryWetMix,
        pingPong: Bool = false
    ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.time.associate(with: self.internalAU, value: time)
            self.feedback.associate(with: self.internalAU, value: feedback)
            self.dryWetMix.associate(with: self.internalAU, value: dryWetMix)
            self.pingPong.associate(with: self.internalAU, value: pingPong)

            input?.connect(to: self)
        }
    }
}
