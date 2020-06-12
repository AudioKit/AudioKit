// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// A delay line with cubic interpolation.
///
open class AKVariableDelay: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "vdla")

    public typealias AKAudioUnitType = AKVariableDelayAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Initial value for Time
    public static let defaultTime: AUValue = 0

    /// Initial value for Feedback
    public static let defaultFeedback: AUValue = 0

    /// Initial value for Maximum Delay Time
    public static let defaultMaximumDelayTime: AUValue = 5

    /// Delay time (in seconds) This value must not exceed the maximum delay time.
    public let time = AKNodeParameter(identifier: "time")

    /// Feedback amount. Should be a value between 0-1.
    public let feedback = AKNodeParameter(identifier: "feedback")

    // MARK: - Initialization

    /// Initialize this delay node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - time: Delay time (in seconds) This value must not exceed the maximum delay time.
    ///   - feedback: Feedback amount. Should be a value between 0-1.
    ///   - maximumDelayTime: The maximum delay time, in seconds.
    ///
    public init(
        _ input: AKNode? = nil,
        time: AUValue = defaultTime,
        feedback: AUValue = defaultFeedback,
        maximumDelayTime: AUValue = defaultMaximumDelayTime
        ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.time.associate(with: self.internalAU, value: time)
            self.feedback.associate(with: self.internalAU, value: feedback)

            input?.connect(to: self)
        }
    }
}
