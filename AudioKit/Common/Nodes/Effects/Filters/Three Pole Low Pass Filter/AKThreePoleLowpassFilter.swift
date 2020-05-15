// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// 3-pole (18 db/oct slope) Low-Pass filter with resonance and tanh distortion.
///
open class AKThreePoleLowpassFilter: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKThreePoleLowpassFilterAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "lp18")

    // MARK: - Properties
    public private(set) var internalAU: AKAudioUnitType?

    /// Lower and upper bounds for Distortion
    public static let distortionRange: ClosedRange<Double> = 0.0 ... 2.0

    /// Lower and upper bounds for Cutoff Frequency
    public static let cutoffFrequencyRange: ClosedRange<Double> = 12.0 ... 20_000.0

    /// Lower and upper bounds for Resonance
    public static let resonanceRange: ClosedRange<Double> = 0.0 ... 2.0

    /// Initial value for Distortion
    public static let defaultDistortion: Double = 0.5

    /// Initial value for Cutoff Frequency
    public static let defaultCutoffFrequency: Double = 1_500

    /// Initial value for Resonance
    public static let defaultResonance: Double = 0.5

    /// Distortion amount.  Zero gives a clean output. Greater than zero adds tanh distortion controlled by the filter parameters, in such a way that both low cutoff and high resonance increase the distortion amount.
    @objc open var distortion: Double = defaultDistortion {
        willSet {
            let clampedValue = AKThreePoleLowpassFilter.distortionRange.clamp(newValue)
            guard distortion != clampedValue else { return }
            internalAU?.distortion.value = AUValue(clampedValue)
        }
    }

    /// Filter cutoff frequency in Hertz.
    @objc open var cutoffFrequency: Double = defaultCutoffFrequency {
        willSet {
            let clampedValue = AKThreePoleLowpassFilter.cutoffFrequencyRange.clamp(newValue)
            guard cutoffFrequency != clampedValue else { return }
            internalAU?.cutoffFrequency.value = AUValue(clampedValue)
        }
    }

    /// Resonance. Usually a value in the range 0-1. A value of 1.0 will self oscillate at the cutoff frequency. Values slightly greater than 1 are possible for more sustained oscillation and an “overdrive” effect.
    @objc open var resonance: Double = defaultResonance {
        willSet {
            let clampedValue = AKThreePoleLowpassFilter.resonanceRange.clamp(newValue)
            guard resonance != clampedValue else { return }
            internalAU?.resonance.value = AUValue(clampedValue)
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
    ///   - distortion: Distortion amount.  Zero gives a clean output. Greater than zero adds tanh distortion controlled by the filter parameters, in such a way that both low cutoff and high resonance increase the distortion amount.
    ///   - cutoffFrequency: Filter cutoff frequency in Hertz.
    ///   - resonance: Resonance. Usually a value in the range 0-1. A value of 1.0 will self oscillate at the cutoff frequency. Values slightly greater than 1 are possible for more sustained oscillation and an “overdrive” effect.
    ///
    public init(
        _ input: AKNode? = nil,
        distortion: Double = defaultDistortion,
        cutoffFrequency: Double = defaultCutoffFrequency,
        resonance: Double = defaultResonance
        ) {
        super.init(avAudioNode: AVAudioNode())

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: self)

            self.distortion = distortion
            self.cutoffFrequency = cutoffFrequency
            self.resonance = resonance
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
