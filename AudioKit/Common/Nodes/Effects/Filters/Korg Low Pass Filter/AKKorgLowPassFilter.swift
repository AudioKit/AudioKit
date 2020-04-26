// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Analogue model of the Korg 35 Lowpass Filter
///
open class AKKorgLowPassFilter: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKKorgLowPassFilterAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "klpf")

    // MARK: - Properties
    public private(set) var internalAU: AKAudioUnitType?

    /// Lower and upper bounds for Cutoff Frequency
    public static let cutoffFrequencyRange: ClosedRange<Double> = 0.0 ... 22_050.0

    /// Lower and upper bounds for Resonance
    public static let resonanceRange: ClosedRange<Double> = 0.0 ... 2.0

    /// Lower and upper bounds for Saturation
    public static let saturationRange: ClosedRange<Double> = 0.0 ... 10.0

    /// Initial value for Cutoff Frequency
    public static let defaultCutoffFrequency: Double = 1_000.0

    /// Initial value for Resonance
    public static let defaultResonance: Double = 1.0

    /// Initial value for Saturation
    public static let defaultSaturation: Double = 0.0

    /// Filter cutoff
    open var cutoffFrequency: Double = defaultCutoffFrequency {
        willSet {
            let clampedValue = AKKorgLowPassFilter.cutoffFrequencyRange.clamp(newValue)
            guard cutoffFrequency != clampedValue else { return }
            internalAU?.cutoffFrequency.value = AUValue(clampedValue)
        }
    }

    /// Filter resonance (should be between 0-2)
    open var resonance: Double = defaultResonance {
        willSet {
            let clampedValue = AKKorgLowPassFilter.resonanceRange.clamp(newValue)
            guard resonance != clampedValue else { return }
            internalAU?.resonance.value = AUValue(clampedValue)
        }
    }

    /// Filter saturation.
    open var saturation: Double = defaultSaturation {
        willSet {
            let clampedValue = AKKorgLowPassFilter.saturationRange.clamp(newValue)
            guard saturation != clampedValue else { return }
            internalAU?.saturation.value = AUValue(clampedValue)
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
    ///   - cutoffFrequency: Filter cutoff
    ///   - resonance: Filter resonance (should be between 0-2)
    ///   - saturation: Filter saturation.
    ///
    public init(
        _ input: AKNode? = nil,
        cutoffFrequency: Double = defaultCutoffFrequency,
        resonance: Double = defaultResonance,
        saturation: Double = defaultSaturation
        ) {
        super.init()

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: self)

            self.cutoffFrequency = cutoffFrequency
            self.resonance = resonance
            self.saturation = saturation
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
