// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Stereo delay-line with stereo (linked dual mono) and ping-pong modes
///
open class AKStereoDelay: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "sdly")

    public typealias AKAudioUnitType = AKStereoDelayAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    public var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Delay time (in seconds) This value must not exceed the maximum delay time.
    @Parameter public var time: AUValue

    /// Feedback amount. Should be a value between 0-1.
    @Parameter public var feedback: AUValue

    /// Dry/wet mix. Should be a value between 0-1.
    @Parameter public var dryWetMix: AUValue

    /// Ping-pong mode: true or false (stereo mode)
    @Parameter public var pingPong: AUValue

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
        maximumDelayTime: AUValue = 2.0,
        time: AUValue = 0,
        feedback: AUValue = 0,
        dryWetMix: AUValue = 0.5,
        pingPong: Bool = false
    ) {
        super.init(avAudioNode: AVAudioNode())

        self.time = time
        self.feedback = feedback
        self.dryWetMix = dryWetMix
        self.pingPong = pingPong ? 1.0 : 0.0

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            input?.connect(to: self)
        }
    }
}
