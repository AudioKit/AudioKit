// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Dynamic range compressor from Faust
///
open class AKDynamicRangeCompressor: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "cpsr")

    public typealias AKAudioUnitType = AKDynamicRangeCompressorAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Lower and upper bounds for Ratio
    public static let ratioRange: ClosedRange<AUValue> = 0.01 ... 100.0

    /// Lower and upper bounds for Threshold
    public static let thresholdRange: ClosedRange<AUValue> = -100.0 ... 0.0

    /// Lower and upper bounds for Attack Duration
    public static let attackDurationRange: ClosedRange<AUValue> = 0.0 ... 1.0

    /// Lower and upper bounds for Release Duration
    public static let releaseDurationRange: ClosedRange<AUValue> = 0.0 ... 1.0

    /// Initial value for Ratio
    public static let defaultRatio: AUValue = 1

    /// Initial value for Threshold
    public static let defaultThreshold: AUValue = 0.0

    /// Initial value for Attack Duration
    public static let defaultAttackDuration: AUValue = 0.1

    /// Initial value for Release Duration
    public static let defaultReleaseDuration: AUValue = 0.1

    /// Ratio to compress with, a value > 1 will compress
    public let ratio = AKNodeParameter(identifier: "ratio")

    /// Threshold (in dB) 0 = max
    public let threshold = AKNodeParameter(identifier: "threshold")

    /// Attack Duration
    public let attackDuration = AKNodeParameter(identifier: "attackTime")

    /// Release Duration
    public let releaseDuration = AKNodeParameter(identifier: "releaseTime")

    // MARK: - Initialization

    /// Initialize this compressor node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - ratio: Ratio to compress with, a value > 1 will compress
    ///   - threshold: Threshold (in dB) 0 = max
    ///   - attackDuration: Attack Duration
    ///   - releaseDuration: Release Duration
    ///
    public init(
        _ input: AKNode? = nil,
        ratio: AUValue = defaultRatio,
        threshold: AUValue = defaultThreshold,
        attackDuration: AUValue = defaultAttackDuration,
        releaseDuration: AUValue = defaultReleaseDuration
        ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.ratio.associate(with: self.internalAU, value: ratio)
            self.threshold.associate(with: self.internalAU, value: threshold)
            self.attackDuration.associate(with: self.internalAU, value: attackDuration)
            self.releaseDuration.associate(with: self.internalAU, value: releaseDuration)

            input?.connect(to: self)
        }
    }
}
