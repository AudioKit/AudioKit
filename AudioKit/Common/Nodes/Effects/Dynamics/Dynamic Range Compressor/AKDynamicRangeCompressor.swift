// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Dynamic range compressor from Faust
///
public class AKDynamicRangeCompressor: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "cpsr")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    public static let ratioDef = AKNodeParameterDef(
        identifier: "ratio",
        name: "Ratio to compress with, a value > 1 will compress",
        address: AKDynamicRangeCompressorParameter.ratio.rawValue,
        range: 0.01 ... 100.0,
        unit: .hertz,
        flags: .default)

    /// Ratio to compress with, a value > 1 will compress
    @Parameter public var ratio: AUValue

    public static let thresholdDef = AKNodeParameterDef(
        identifier: "threshold",
        name: "Threshold (in dB) 0 = max",
        address: AKDynamicRangeCompressorParameter.threshold.rawValue,
        range: -100.0 ... 0.0,
        unit: .generic,
        flags: .default)

    /// Threshold (in dB) 0 = max
    @Parameter public var threshold: AUValue

    public static let attackDurationDef = AKNodeParameterDef(
        identifier: "attackDuration",
        name: "Attack duration",
        address: AKDynamicRangeCompressorParameter.attackDuration.rawValue,
        range: 0.0 ... 1.0,
        unit: .seconds,
        flags: .default)

    /// Attack duration
    @Parameter public var attackDuration: AUValue

    public static let releaseDurationDef = AKNodeParameterDef(
        identifier: "releaseDuration",
        name: "Release duration",
        address: AKDynamicRangeCompressorParameter.releaseDuration.rawValue,
        range: 0.0 ... 1.0,
        unit: .seconds,
        flags: .default)

    /// Release Duration
    @Parameter public var releaseDuration: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            return [AKDynamicRangeCompressor.ratioDef,
                    AKDynamicRangeCompressor.thresholdDef,
                    AKDynamicRangeCompressor.attackDurationDef,
                    AKDynamicRangeCompressor.releaseDurationDef]
        }

        public override func createDSP() -> AKDSPRef {
            return createDynamicRangeCompressorDSP()
        }
    }

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
