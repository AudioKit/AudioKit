// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Dynamic range compressor from Faust
///
open class AKDynamicRangeCompressor: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKDynamicRangeCompressorAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "cpsr")

    // MARK: - Properties
    public private(set) var internalAU: AKAudioUnitType?

    /// Lower and upper bounds for Ratio
    public static let ratioRange: ClosedRange<Double> = 0.01 ... 100.0

    /// Lower and upper bounds for Threshold
    public static let thresholdRange: ClosedRange<Double> = -100.0 ... 0.0

    /// Lower and upper bounds for Attack Time
    public static let attackDurationRange: ClosedRange<Double> = 0.0 ... 1.0

    /// Lower and upper bounds for Release Time
    public static let releaseDurationRange: ClosedRange<Double> = 0.0 ... 1.0

    /// Initial value for Ratio
    public static let defaultRatio: Double = 1

    /// Initial value for Threshold
    public static let defaultThreshold: Double = 0.0

    /// Initial value for Attack Time
    public static let defaultAttackDuration: Double = 0.1

    /// Initial value for Release Time
    public static let defaultReleaseDuration: Double = 0.1

    /// Ratio to compress with, a value > 1 will compress
    @objc open var ratio: Double = defaultRatio {
        willSet {
            let clampedValue = AKDynamicRangeCompressor.ratioRange.clamp(newValue)
            guard ratio != clampedValue else { return }
            internalAU?.ratio.value = AUValue(clampedValue)
        }
    }

    /// Threshold (in dB) 0 = max
    @objc open var threshold: Double = defaultThreshold {
        willSet {
            let clampedValue = AKDynamicRangeCompressor.thresholdRange.clamp(newValue)
            guard threshold != clampedValue else { return }
            internalAU?.threshold.value = AUValue(clampedValue)
        }
    }

    /// Attack time
    open var attackDuration: Double = defaultAttackDuration {
        willSet {
            let clampedValue = AKDynamicRangeCompressor.attackDurationRange.clamp(newValue)
            guard attackDuration != clampedValue else { return }
            internalAU?.attackTime.value = AUValue(clampedValue)
        }
    }

    /// Release time
    open var releaseDuration: Double = defaultReleaseDuration {
        willSet {
            let clampedValue = AKDynamicRangeCompressor.releaseDurationRange.clamp(newValue)
            guard releaseDuration != clampedValue else { return }
            internalAU?.releaseTime.value = AUValue(clampedValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    // MARK: - Initialization

    /// Initialize this compressor node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - ratio: Ratio to compress with, a value > 1 will compress
    ///   - threshold: Threshold (in dB) 0 = max
    ///   - attackTime: Attack time
    ///   - releaseTime: Release time
    ///
    public init(
        _ input: AKNode? = nil,
        ratio: Double = defaultRatio,
        threshold: Double = defaultThreshold,
        attackDuration: Double = defaultAttackDuration,
        releaseDuration: Double = defaultReleaseDuration
        ) {
        super.init()

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: self)

            self.ratio = ratio
            self.threshold = threshold
            self.attackDuration = attackDuration
            self.releaseDuration = releaseDuration
        }
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        internalAU?.stop()
    }
}
