// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Emulation of the Roland TB-303 filter
///
open class AKRolandTB303Filter: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKRolandTB303FilterAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "tb3f")

    // MARK: - Properties
    public private(set) var internalAU: AKAudioUnitType?

    /// Lower and upper bounds for Cutoff Frequency
    public static let cutoffFrequencyRange: ClosedRange<Double> = 12.0 ... 20_000.0

    /// Lower and upper bounds for Resonance
    public static let resonanceRange: ClosedRange<Double> = 0.0 ... 2.0

    /// Lower and upper bounds for Distortion
    public static let distortionRange: ClosedRange<Double> = 0.0 ... 4.0

    /// Lower and upper bounds for Resonance Asymmetry
    public static let resonanceAsymmetryRange: ClosedRange<Double> = 0.0 ... 1.0

    /// Initial value for Cutoff Frequency
    public static let defaultCutoffFrequency: Double = 500

    /// Initial value for Resonance
    public static let defaultResonance: Double = 0.5

    /// Initial value for Distortion
    public static let defaultDistortion: Double = 2.0

    /// Initial value for Resonance Asymmetry
    public static let defaultResonanceAsymmetry: Double = 0.5

    /// Cutoff frequency. (in Hertz)
    @objc open var cutoffFrequency: Double = defaultCutoffFrequency {
        willSet {
            let clampedValue = AKRolandTB303Filter.cutoffFrequencyRange.clamp(newValue)
            guard cutoffFrequency != clampedValue else { return }
            internalAU?.cutoffFrequency.value = AUValue(clampedValue)
        }
    }

    /// Resonance, generally < 1, but not limited to it. Higher than 1 resonance values might cause aliasing, analogue synths generally allow resonances to be above 1.
    @objc open var resonance: Double = defaultResonance {
        willSet {
            let clampedValue = AKRolandTB303Filter.resonanceRange.clamp(newValue)
            guard resonance != clampedValue else { return }
            internalAU?.resonance.value = AUValue(clampedValue)
        }
    }

    /// Distortion. Value is typically 2.0; deviation from this can cause stability issues. 
    @objc open var distortion: Double = defaultDistortion {
        willSet {
            let clampedValue = AKRolandTB303Filter.distortionRange.clamp(newValue)
            guard distortion != clampedValue else { return }
            internalAU?.distortion.value = AUValue(clampedValue)
        }
    }

    /// Asymmetry of resonance. Value is between 0-1
    @objc open var resonanceAsymmetry: Double = defaultResonanceAsymmetry {
        willSet {
            let clampedValue = AKRolandTB303Filter.resonanceAsymmetryRange.clamp(newValue)
            guard resonanceAsymmetry != clampedValue else { return }
            internalAU?.resonanceAsymmetry.value = AUValue(clampedValue)
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
    ///   - cutoffFrequency: Cutoff frequency. (in Hertz)
    ///   - resonance: Resonance, generally < 1, but not limited to it. Higher than 1 resonance values might cause aliasing, analogue synths generally allow resonances to be above 1.
    ///   - distortion: Distortion. Value is typically 2.0; deviation from this can cause stability issues. 
    ///   - resonanceAsymmetry: Asymmetry of resonance. Value is between 0-1
    ///
    public init(
        _ input: AKNode? = nil,
        cutoffFrequency: Double = defaultCutoffFrequency,
        resonance: Double = defaultResonance,
        distortion: Double = defaultDistortion,
        resonanceAsymmetry: Double = defaultResonanceAsymmetry
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
            self.distortion = distortion
            self.resonanceAsymmetry = resonanceAsymmetry
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
