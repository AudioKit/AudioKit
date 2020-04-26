// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// This will digitally degrade a signal.
///
open class AKBitCrusher: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKBitCrusherAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "btcr")

    // MARK: - Properties
    public private(set) var internalAU: AKAudioUnitType?

    /// Lower and upper bounds for Bit Depth
    public static let bitDepthRange: ClosedRange<Double> = 1 ... 24

    /// Lower and upper bounds for Sample Rate
    public static let sampleRateRange: ClosedRange<Double> = 0.0 ... 20_000.0

    /// Initial value for Bit Depth
    public static let defaultBitDepth: Double = 8

    /// Initial value for Sample Rate
    public static let defaultSampleRate: Double = 10_000

    /// The bit depth of signal output. Typically in range (1-24). Non-integer values are OK.
    open var bitDepth: Double = defaultBitDepth {
        willSet {
            let clampedValue = AKBitCrusher.bitDepthRange.clamp(newValue)
            guard bitDepth != clampedValue else { return }
            internalAU?.bitDepth.value = AUValue(clampedValue)
        }
    }

    /// The sample rate of signal output.
    open var sampleRate: Double = defaultSampleRate {
        willSet {
            let clampedValue = AKBitCrusher.sampleRateRange.clamp(newValue)
            guard sampleRate != clampedValue else { return }
            internalAU?.sampleRate.value = AUValue(clampedValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

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
        bitDepth: Double = defaultBitDepth,
        sampleRate: Double = defaultSampleRate
        ) {
        super.init()

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: self)

            self.bitDepth = bitDepth
            self.sampleRate = sampleRate
        }
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        internalAU?.stop()
    }
}
