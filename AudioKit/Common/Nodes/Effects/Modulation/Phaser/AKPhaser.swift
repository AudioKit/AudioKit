// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// A stereo phaser This is a stereo phaser, generated from Faust code taken
/// from the Guitarix project.
///
open class AKPhaser: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "phas")

    public typealias AKAudioUnitType = AKPhaserAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Lower and upper bounds for Notch Minimum Frequency
    public static let notchMinimumFrequencyRange: ClosedRange<AUValue> = 20 ... 5_000

    /// Lower and upper bounds for Notch Maximum Frequency
    public static let notchMaximumFrequencyRange: ClosedRange<AUValue> = 20 ... 10_000

    /// Lower and upper bounds for Notch Width
    public static let notchWidthRange: ClosedRange<AUValue> = 10 ... 5_000

    /// Lower and upper bounds for Notch Frequency
    public static let notchFrequencyRange: ClosedRange<AUValue> = 1.1 ... 4.0

    /// Lower and upper bounds for Vibrato Mode
    public static let vibratoModeRange: ClosedRange<AUValue> = 0 ... 1

    /// Lower and upper bounds for Depth
    public static let depthRange: ClosedRange<AUValue> = 0 ... 1

    /// Lower and upper bounds for Feedback
    public static let feedbackRange: ClosedRange<AUValue> = 0 ... 1

    /// Lower and upper bounds for Inverted
    public static let invertedRange: ClosedRange<AUValue> = 0 ... 1

    /// Lower and upper bounds for Lfo Bpm
    public static let lfoBPMRange: ClosedRange<AUValue> = 24 ... 360

    /// Initial value for Notch Minimum Frequency
    public static let defaultNotchMinimumFrequency: AUValue = 100

    /// Initial value for Notch Maximum Frequency
    public static let defaultNotchMaximumFrequency: AUValue = 800

    /// Initial value for Notch Width
    public static let defaultNotchWidth: AUValue = 1_000

    /// Initial value for Notch Frequency
    public static let defaultNotchFrequency: AUValue = 1.5

    /// Initial value for Vibrato Mode
    public static let defaultVibratoMode: AUValue = 1

    /// Initial value for Depth
    public static let defaultDepth: AUValue = 1

    /// Initial value for Feedback
    public static let defaultFeedback: AUValue = 0

    /// Initial value for Inverted
    public static let defaultInverted: AUValue = 0

    /// Initial value for Lfo Bpm
    public static let defaultLfoBPM: AUValue = 30

    /// Notch Minimum Frequency
    public let notchMinimumFrequency = AKNodeParameter(identifier: "notchMinimumFrequency")

    /// Notch Maximum Frequency
    public let notchMaximumFrequency = AKNodeParameter(identifier: "notchMaximumFrequency")

    /// Between 10 and 5000
    public let notchWidth = AKNodeParameter(identifier: "notchWidth")

    /// Between 1.1 and 4
    public let notchFrequency = AKNodeParameter(identifier: "notchFrequency")

    /// Direct or Vibrato (default)
    public let vibratoMode = AKNodeParameter(identifier: "vibratoMode")

    /// Between 0 and 1
    public let depth = AKNodeParameter(identifier: "depth")

    /// Between 0 and 1
    public let feedback = AKNodeParameter(identifier: "feedback")

    /// 1 or 0
    public let inverted = AKNodeParameter(identifier: "inverted")

    /// Between 24 and 360
    public let lfoBPM = AKNodeParameter(identifier: "lfoBPM")

    // MARK: - Initialization

    /// Initialize this phaser node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - notchMinimumFrequency: Notch Minimum Frequency
    ///   - notchMaximumFrequency: Notch Maximum Frequency
    ///   - notchWidth: Between 10 and 5000
    ///   - notchFrequency: Between 1.1 and 4
    ///   - vibratoMode: Direct or Vibrato (default)
    ///   - depth: Between 0 and 1
    ///   - feedback: Between 0 and 1
    ///   - inverted: 1 or 0
    ///   - lfoBPM: Between 24 and 360
    ///
    public init(
        _ input: AKNode? = nil,
        notchMinimumFrequency: AUValue = defaultNotchMinimumFrequency,
        notchMaximumFrequency: AUValue = defaultNotchMaximumFrequency,
        notchWidth: AUValue = defaultNotchWidth,
        notchFrequency: AUValue = defaultNotchFrequency,
        vibratoMode: AUValue = defaultVibratoMode,
        depth: AUValue = defaultDepth,
        feedback: AUValue = defaultFeedback,
        inverted: AUValue = defaultInverted,
        lfoBPM: AUValue = defaultLfoBPM
        ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.notchMinimumFrequency.associate(with: self.internalAU, value: notchMinimumFrequency)
            self.notchMaximumFrequency.associate(with: self.internalAU, value: notchMaximumFrequency)
            self.notchWidth.associate(with: self.internalAU, value: notchWidth)
            self.notchFrequency.associate(with: self.internalAU, value: notchFrequency)
            self.vibratoMode.associate(with: self.internalAU, value: vibratoMode)
            self.depth.associate(with: self.internalAU, value: depth)
            self.feedback.associate(with: self.internalAU, value: feedback)
            self.inverted.associate(with: self.internalAU, value: inverted)
            self.lfoBPM.associate(with: self.internalAU, value: lfoBPM)

            input?.connect(to: self)
        }
    }
}
