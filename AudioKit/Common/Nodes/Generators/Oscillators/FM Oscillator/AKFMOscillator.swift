// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Classic FM Synthesis audio generation.
///
open class AKFMOscillator: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKFMOscillatorAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "fosc")

    // MARK: - Properties

    public private(set) var internalAU: AKAudioUnitType?

    fileprivate var waveform: AKTable?

    /// Lower and upper bounds for Base Frequency
    public static let baseFrequencyRange: ClosedRange<Double> = 0.0 ... 20_000.0

    /// Lower and upper bounds for Carrier Multiplier
    public static let carrierMultiplierRange: ClosedRange<Double> = 0.0 ... 1_000.0

    /// Lower and upper bounds for Modulating Multiplier
    public static let modulatingMultiplierRange: ClosedRange<Double> = 0.0 ... 1_000.0

    /// Lower and upper bounds for Modulation Index
    public static let modulationIndexRange: ClosedRange<Double> = 0.0 ... 1_000.0

    /// Lower and upper bounds for Amplitude
    public static let amplitudeRange: ClosedRange<Double> = 0.0 ... 10.0

    /// Initial value for Base Frequency
    public static let defaultBaseFrequency: Double = 440.0

    /// Initial value for Carrier Multiplier
    public static let defaultCarrierMultiplier: Double = 1.0

    /// Initial value for Modulating Multiplier
    public static let defaultModulatingMultiplier: Double = 1.0

    /// Initial value for Modulation Index
    public static let defaultModulationIndex: Double = 1.0

    /// Initial value for Amplitude
    public static let defaultAmplitude: Double = 1.0

    /// In cycles per second, or Hz, this is the common denominator for the carrier and modulating frequencies.
    open var baseFrequency: Double = defaultBaseFrequency {
        willSet {
            let clampedValue = AKFMOscillator.baseFrequencyRange.clamp(newValue)
            guard baseFrequency != clampedValue else { return }
            internalAU?.baseFrequency.value = AUValue(clampedValue)
        }
    }

    /// This multiplied by the baseFrequency gives the carrier frequency.
    open var carrierMultiplier: Double = defaultCarrierMultiplier {
        willSet {
            let clampedValue = AKFMOscillator.carrierMultiplierRange.clamp(newValue)
            guard carrierMultiplier != clampedValue else { return }
            internalAU?.carrierMultiplier.value = AUValue(clampedValue)
        }
    }

    /// This multiplied by the baseFrequency gives the modulating frequency.
    open var modulatingMultiplier: Double = defaultModulatingMultiplier {
        willSet {
            let clampedValue = AKFMOscillator.modulatingMultiplierRange.clamp(newValue)
            guard modulatingMultiplier != clampedValue else { return }
            internalAU?.modulatingMultiplier.value = AUValue(clampedValue)
        }
    }

    /// This multiplied by the modulating frequency gives the modulation amplitude.
    open var modulationIndex: Double = defaultModulationIndex {
        willSet {
            let clampedValue = AKFMOscillator.modulationIndexRange.clamp(newValue)
            guard modulationIndex != clampedValue else { return }
            internalAU?.modulationIndex.value = AUValue(clampedValue)
        }
    }

    /// Output Amplitude.
    open var amplitude: Double = defaultAmplitude {
        willSet {
            let clampedValue = AKFMOscillator.amplitudeRange.clamp(newValue)
            guard amplitude != clampedValue else { return }
            internalAU?.amplitude.value = AUValue(clampedValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    // MARK: - Initialization

    /// Initialize the oscillator with defaults
    public convenience override init() {
        self.init(waveform: AKTable(.sine))
    }

    /// Initialize this oscillator node
    ///
    /// - Parameters:
    ///   - waveform: The waveform of oscillation
    ///   - baseFrequency: In cycles per second, or Hz, this is the common denominator for the carrier and modulating frequencies.
    ///   - carrierMultiplier: This multiplied by the baseFrequency gives the carrier frequency.
    ///   - modulatingMultiplier: This multiplied by the baseFrequency gives the modulating frequency.
    ///   - modulationIndex: This multiplied by the modulating frequency gives the modulation amplitude.
    ///   - amplitude: Output Amplitude.
    ///
    public init(
        waveform: AKTable,
        baseFrequency: Double = defaultBaseFrequency,
        carrierMultiplier: Double = defaultCarrierMultiplier,
        modulatingMultiplier: Double = defaultModulatingMultiplier,
        modulationIndex: Double = defaultModulationIndex,
        amplitude: Double = defaultAmplitude
    ) {
        super.init()

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            self.waveform = waveform
            self.baseFrequency = baseFrequency
            self.carrierMultiplier = carrierMultiplier
            self.modulatingMultiplier = modulatingMultiplier
            self.modulationIndex = modulationIndex
            self.amplitude = amplitude

            self.internalAU?.setWavetable(waveform.content)
        }
    }

    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        internalAU?.stop()
    }
}
