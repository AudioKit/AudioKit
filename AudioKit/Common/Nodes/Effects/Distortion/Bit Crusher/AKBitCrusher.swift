// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// This will digitally degrade a signal.
///
open class AKBitCrusher: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "btcr")

    public typealias AKAudioUnitType = AKBitCrusherAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// The bit depth of signal output. Typically in range (1-24). Non-integer values are OK.
    @Parameter public var bitDepth: AUValue

    /// The sample rate of signal output.
    @Parameter public var sampleRate: AUValue

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
        bitDepth: AUValue = 8,
        sampleRate: AUValue = 10_000
        ) {
        super.init(avAudioNode: AVAudioNode())
        self.bitDepth = bitDepth
        self.sampleRate = sampleRate
        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            input?.connect(to: self)
        }
    }
}
