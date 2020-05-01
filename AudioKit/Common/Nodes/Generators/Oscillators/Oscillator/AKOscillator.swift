// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Reads from the table sequentially and repeatedly at given frequency. Linear
/// interpolation is applied for table look up from internal phase values.
///
open class AKOscillator: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKOscillatorAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "oscl")

    // MARK: - Properties

    public private(set) var internalAU: AKAudioUnitType?

    fileprivate var waveform: AKTable?

    /// Lower and upper bounds for Frequency
    public static let frequencyRange: ClosedRange<Double> = 0.0 ... 20_000.0

    /// Lower and upper bounds for Amplitude
    public static let amplitudeRange: ClosedRange<Double> = 0.0 ... 10.0

    /// Lower and upper bounds for Detuning Offset
    public static let detuningOffsetRange: ClosedRange<Double> = -1_000.0 ... 1_000.0

    /// Lower and upper bounds for Detuning Multiplier
    public static let detuningMultiplierRange: ClosedRange<Double> = 0.9 ... 1.11

    /// Initial value for Frequency
    public static let defaultFrequency: Double = 440.0

    /// Initial value for Amplitude
    public static let defaultAmplitude: Double = 1.0

    /// Initial value for Detuning Offset
    public static let defaultDetuningOffset: Double = 0.0

    /// Initial value for Detuning Multiplier
    public static let defaultDetuningMultiplier: Double = 1.0

    /// Frequency in cycles per second
    open var frequency: Double = defaultFrequency {
        willSet {
            let clampedValue = AKOscillator.frequencyRange.clamp(newValue)
            guard frequency != clampedValue else { return }
            internalAU?.frequency.value = AUValue(clampedValue)
        }
    }

    /// Output Amplitude.
    open var amplitude: Double = defaultAmplitude {
        willSet {
            let clampedValue = AKOscillator.amplitudeRange.clamp(newValue)
            guard amplitude != clampedValue else { return }
            internalAU?.amplitude.value = AUValue(clampedValue)
        }
    }

    /// Frequency offset in Hz.
    open var detuningOffset: Double = defaultDetuningOffset {
        willSet {
            let clampedValue = AKOscillator.detuningOffsetRange.clamp(newValue)
            guard detuningOffset != clampedValue else { return }
            internalAU?.detuningOffset.value = AUValue(clampedValue)
        }
    }

    /// Frequency detuning multiplier
    open var detuningMultiplier: Double = defaultDetuningMultiplier {
        willSet {
            let clampedValue = AKOscillator.detuningMultiplierRange.clamp(newValue)
            guard detuningMultiplier != clampedValue else { return }
            internalAU?.detuningMultiplier.value = AUValue(clampedValue)
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
    ///   - frequency: Frequency in cycles per second
    ///   - amplitude: Output Amplitude.
    ///   - detuningOffset: Frequency offset in Hz.
    ///   - detuningMultiplier: Frequency detuning multiplier
    ///
    public init(
        waveform: AKTable,
        frequency: Double = defaultFrequency,
        amplitude: Double = defaultAmplitude,
        detuningOffset: Double = defaultDetuningOffset,
        detuningMultiplier: Double = defaultDetuningMultiplier
    ) {
        super.init()

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            self.waveform = waveform
            self.frequency = frequency
            self.amplitude = amplitude
            self.detuningOffset = detuningOffset
            self.detuningMultiplier = detuningMultiplier

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
