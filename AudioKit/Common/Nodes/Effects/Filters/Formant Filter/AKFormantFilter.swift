// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// When fed with a pulse train, it will generate a series of overlapping
/// grains. Overlapping will occur when 1/freq < dec, but there is no upper
/// limit on the number of overlaps.
///
open class AKFormantFilter: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKFormantFilterAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "fofi")

    // MARK: - Properties
    public private(set) var internalAU: AKAudioUnitType?

    /// Lower and upper bounds for Center Frequency
    public static let centerFrequencyRange: ClosedRange<Double> = 12.0 ... 20_000.0

    /// Lower and upper bounds for Attack Duration
    public static let attackDurationRange: ClosedRange<Double> = 0.0 ... 0.1

    /// Lower and upper bounds for Decay Duration
    public static let decayDurationRange: ClosedRange<Double> = 0.0 ... 0.1

    /// Initial value for Center Frequency
    public static let defaultCenterFrequency: Double = 1_000

    /// Initial value for Attack Duration
    public static let defaultAttackDuration: Double = 0.007

    /// Initial value for Decay Duration
    public static let defaultDecayDuration: Double = 0.04

    /// Center frequency.
    open var centerFrequency: Double = defaultCenterFrequency {
        willSet {
            let clampedValue = AKFormantFilter.centerFrequencyRange.clamp(newValue)
            guard centerFrequency != clampedValue else { return }
            internalAU?.centerFrequency.value = AUValue(clampedValue)
        }
    }

    /// Impulse response attack time (in seconds).
    open var attackDuration: Double = defaultAttackDuration {
        willSet {
            let clampedValue = AKFormantFilter.attackDurationRange.clamp(newValue)
            guard attackDuration != clampedValue else { return }
            internalAU?.attackDuration.value = AUValue(clampedValue)
        }
    }

    /// Impulse reponse decay time (in seconds)
    open var decayDuration: Double = defaultDecayDuration {
        willSet {
            let clampedValue = AKFormantFilter.decayDurationRange.clamp(newValue)
            guard decayDuration != clampedValue else { return }
            internalAU?.decayDuration.value = AUValue(clampedValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - centerFrequency: Center frequency.
    ///   - attackDuration: Impulse response attack time (in seconds).
    ///   - decayDuration: Impulse reponse decay time (in seconds)
    ///
    public init(
        _ input: AKNode? = nil,
        centerFrequency: Double = defaultCenterFrequency,
        attackDuration: Double = defaultAttackDuration,
        decayDuration: Double = defaultDecayDuration
        ) {
        super.init()

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: self)

            self.centerFrequency = centerFrequency
            self.attackDuration = attackDuration
            self.decayDuration = decayDuration
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
