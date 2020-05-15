// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// This is an oscillator with linear interpolation that is capable of morphing
/// between an arbitrary number of wavetables.
///
open class AKMorphingOscillator: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKMorphingOscillatorAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "morf")

    // MARK: - Properties

    public private(set) var internalAU: AKAudioUnitType?

    fileprivate var waveformArray = [AKTable]()

    /// Lower and upper bounds for Frequency
    public static let frequencyRange: ClosedRange<Double> = 0.0 ... 22_050.0

    /// Lower and upper bounds for Amplitude
    public static let amplitudeRange: ClosedRange<Double> = 0.0 ... 1.0

    /// Lower and upper bounds for Index
    public static let indexRange: ClosedRange<Double> = 0.0 ... 3.0

    /// Lower and upper bounds for Detuning Offset
    public static let detuningOffsetRange: ClosedRange<Double> = -1_000.0 ... 1_000.0

    /// Lower and upper bounds for Detuning Multiplier
    public static let detuningMultiplierRange: ClosedRange<Double> = 0.9 ... 1.11

    /// Initial value for Frequency
    public static let defaultFrequency: Double = 440

    /// Initial value for Amplitude
    public static let defaultAmplitude: Double = 0.5

    /// Initial value for Index
    public static let defaultIndex: Double = 0.0

    /// Initial value for Detuning Offset
    public static let defaultDetuningOffset: Double = 0

    /// Initial value for Detuning Multiplier
    public static let defaultDetuningMultiplier: Double = 1

    /// Initial value for Phase
    public static let defaultPhase: Double = 0

    /// Frequency (in Hz)
    @objc open var frequency: Double = defaultFrequency {
        willSet {
            let clampedValue = AKMorphingOscillator.frequencyRange.clamp(newValue)
            guard frequency != clampedValue else { return }
            internalAU?.frequency.value = AUValue(clampedValue)
        }
    }

    /// Amplitude (typically a value between 0 and 1).
    @objc open var amplitude: Double = defaultAmplitude {
        willSet {
            let clampedValue = AKMorphingOscillator.amplitudeRange.clamp(newValue)
            guard amplitude != clampedValue else { return }
            internalAU?.amplitude.value = AUValue(clampedValue)
        }
    }

    /// Index of the wavetable to use (fractional are okay).
    @objc open var index: Double = defaultIndex {
        willSet {
            let clampedValue = AKMorphingOscillator.indexRange.clamp(newValue)
            guard index != clampedValue else { return }
            let transformedValue = clampedValue / (waveformArray.count - 1)
            internalAU?.index.value = AUValue(transformedValue)
        }
    }

    /// Frequency offset in Hz.
    @objc open var detuningOffset: Double = defaultDetuningOffset {
        willSet {
            let clampedValue = AKMorphingOscillator.detuningOffsetRange.clamp(newValue)
            guard detuningOffset != clampedValue else { return }
            internalAU?.detuningOffset.value = AUValue(clampedValue)
        }
    }

    /// Frequency detuning multiplier
    @objc open var detuningMultiplier: Double = defaultDetuningMultiplier {
        willSet {
            let clampedValue = AKMorphingOscillator.detuningMultiplierRange.clamp(newValue)
            guard detuningMultiplier != clampedValue else { return }
            internalAU?.detuningMultiplier.value = AUValue(clampedValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    // MARK: - Initialization

    /// Initialize this Morpher node
    ///
    /// - Parameters:
    ///   - waveformArray: An array of exactly four waveforms
    ///   - frequency: Frequency (in Hz)
    ///   - amplitude: Amplitude (typically a value between 0 and 1).
    ///   - index: Index of the wavetable to use (fractional are okay).
    ///   - detuningOffset: Frequency offset in Hz.
    ///   - detuningMultiplier: Frequency detuning multiplier
    ///   - waveformCount: Number of waveforms.
    ///   - phase: Initial phase of waveform, expects a value 0-1
    ///
    public init(
        waveformArray: [AKTable] = [AKTable(.triangle), AKTable(.square), AKTable(.sine), AKTable(.sawtooth)],
        frequency: Double = defaultFrequency,
        amplitude: Double = defaultAmplitude,
        index: Double = defaultIndex,
        detuningOffset: Double = defaultDetuningOffset,
        detuningMultiplier: Double = defaultDetuningMultiplier,
        phase: Double = defaultPhase
    ) {
        super.init(avAudioNode: AVAudioNode())

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            self.waveformArray = waveformArray
            self.frequency = frequency
            self.amplitude = amplitude
            self.index = index
            self.detuningOffset = detuningOffset
            self.detuningMultiplier = detuningMultiplier

            for (i, waveform) in waveformArray.enumerated() {
                self.internalAU?.setWavetable(waveform.content, index: i)
            }
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
