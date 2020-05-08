// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// A modal resonance filter used for modal synthesis. Plucked and bell sounds
/// can be created using  passing an impulse through a combination of modal
/// filters.
///
open class AKModalResonanceFilter: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKModalResonanceFilterAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "modf")

    // MARK: - Properties
    public private(set) var internalAU: AKAudioUnitType?

    /// Lower and upper bounds for Frequency
    public static let frequencyRange: ClosedRange<Double> = 12.0 ... 20_000.0

    /// Lower and upper bounds for Quality Factor
    public static let qualityFactorRange: ClosedRange<Double> = 0.0 ... 100.0

    /// Initial value for Frequency
    public static let defaultFrequency: Double = 500.0

    /// Initial value for Quality Factor
    public static let defaultQualityFactor: Double = 50.0

    /// Resonant frequency of the filter.
    @objc open var frequency: Double = defaultFrequency {
        willSet {
            let clampedValue = AKModalResonanceFilter.frequencyRange.clamp(newValue)
            guard frequency != clampedValue else { return }
            internalAU?.frequency.value = AUValue(clampedValue)
        }
    }

    /// Quality factor of the filter. Roughly equal to Q/frequency.
    @objc open var qualityFactor: Double = defaultQualityFactor {
        willSet {
            let clampedValue = AKModalResonanceFilter.qualityFactorRange.clamp(newValue)
            guard qualityFactor != clampedValue else { return }
            internalAU?.qualityFactor.value = AUValue(clampedValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - frequency: Resonant frequency of the filter.
    ///   - qualityFactor: Quality factor of the filter. Roughly equal to Q/frequency.
    ///
    public init(
        _ input: AKNode? = nil,
        frequency: Double = defaultFrequency,
        qualityFactor: Double = defaultQualityFactor
        ) {
        super.init()

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: self)

            self.frequency = frequency
            self.qualityFactor = qualityFactor
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
