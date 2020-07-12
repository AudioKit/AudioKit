// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Dynamic range compressor from Faust
///
open class AKDynamicRangeCompressor: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "cpsr")

    public typealias AKAudioUnitType = AKDynamicRangeCompressorAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Ratio to compress with, a value > 1 will compress
    @Parameter public var ratio: AUValue

    /// Threshold (in dB) 0 = max
    @Parameter public var threshold: AUValue

    /// Attack duration
    @Parameter public var attackDuration: AUValue

    /// Release Duration
    @Parameter public var releaseDuration: AUValue

    // MARK: - Initialization

    /// Initialize this compressor node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - ratio: Ratio to compress with, a value > 1 will compress
    ///   - threshold: Threshold (in dB) 0 = max
    ///   - attackDuration: Attack duration
    ///   - releaseDuration: Release Duration
    ///
    public init(
        _ input: AKNode? = nil,
        ratio: AUValue = 1,
        threshold: AUValue = 0.0,
        attackDuration: AUValue = 0.1,
        releaseDuration: AUValue = 0.1
        ) {
        super.init(avAudioNode: AVAudioNode())
        self.ratio = ratio
        self.threshold = threshold
        self.attackDuration = attackDuration
        self.releaseDuration = releaseDuration
        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            input?.connect(to: self)
        }
    }
}
