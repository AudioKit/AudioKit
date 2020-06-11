// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// This will digitally degrade a signal.
///
open class AKBitCrusher: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "btcr")

    public typealias AKAudioUnitType = AKBitCrusherAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Lower and upper bounds for Bit Depth
    public static let bitDepthRange: ClosedRange<AUValue> = 1 ... 24

    /// Lower and upper bounds for Sample Rate
    public static let sampleRateRange: ClosedRange<AUValue> = 0.0 ... 20_000.0

    /// Initial value for Bit Depth
    public static let defaultBitDepth: AUValue = 8

    /// Initial value for Sample Rate
    public static let defaultSampleRate: AUValue = 10_000

    /// The bit depth of signal output. Typically in range (1-24). Non-integer values are OK.
    public let bitDepth = AKNodeParameter(identifier: "bitDepth")

    /// The sample rate of signal output.
    public let sampleRate = AKNodeParameter(identifier: "sampleRate")

    // MARK: - Initialization

    /// Initialize this bitcrusher node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - bitDepth: The bit depth of signal output. Typically in range (1-24). Non-integer values are OK.
    ///   - sampleRate: The sample rate of signal output.
    ///
    public init(
        _ input: AKNode? = nil,
        bitDepth: AUValue = defaultBitDepth,
        sampleRate: AUValue = defaultSampleRate
        ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.bitDepth.associate(with: self.internalAU, value: bitDepth)
            self.sampleRate.associate(with: self.internalAU, value: sampleRate)

            input?.connect(to: self)
        }
    }
}
