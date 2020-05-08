// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Casio-style phase distortion with "pivot point" on the X axis This module is
/// designed to emulate the classic phase distortion synthesis technique. From
/// the mid 90's. The technique reads the first and second halves of the ftbl at
/// different rates in order to warp the waveform. For example, pdhalf can
/// smoothly transition a sinewave into something approximating a sawtooth wave.
///
open class AKPhaseDistortionOscillator: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKPhaseDistortionOscillatorAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "pdho")

    // MARK: - Properties

    public private(set) var internalAU: AKAudioUnitType?

    fileprivate var waveform: AKTable?

    /// Lower and upper bounds for Frequency
    public static let frequencyRange: ClosedRange<Double> = 0 ... 20_000

    /// Lower and upper bounds for Amplitude
    public static let amplitudeRange: ClosedRange<Double> = 0 ... 10

    /// Lower and upper bounds for Phase Distortion
    public static let phaseDistortionRange: ClosedRange<Double> = -1 ... 1

    /// Lower and upper bounds for Detuning Offset
    public static let detuningOffsetRange: ClosedRange<Double> = -1_000 ... 1_000

    /// Lower and upper bounds for Detuning Multiplier
    public static let detuningMultiplierRange: ClosedRange<Double> = 0.9 ... 1.11

    /// Initial value for Frequency
    public static let defaultFrequency: Double = 440

    /// Initial value for Amplitude
    public static let defaultAmplitude: Double = 1

    /// Initial value for Phase Distortion
    public static let defaultPhaseDistortion: Double = 0

    /// Initial value for Detuning Offset
    public static let defaultDetuningOffset: Double = 0

    /// Initial value for Detuning Multiplier
    public static let defaultDetuningMultiplier: Double = 1

    /// Frequency in cycles per second
    @objc open var frequency: Double = defaultFrequency {
        willSet {
            let clampedValue = AKPhaseDistortionOscillator.frequencyRange.clamp(newValue)
            guard frequency != clampedValue else { return }
            internalAU?.frequency.value = AUValue(clampedValue)
        }
    }

    /// Output Amplitude.
    @objc open var amplitude: Double = defaultAmplitude {
        willSet {
            let clampedValue = AKPhaseDistortionOscillator.amplitudeRange.clamp(newValue)
            guard amplitude != clampedValue else { return }
            internalAU?.amplitude.value = AUValue(clampedValue)
        }
    }

    /// Amount of distortion, within the range [-1, 1]. 0 is no distortion.
    @objc open var phaseDistortion: Double = defaultPhaseDistortion {
        willSet {
            let clampedValue = AKPhaseDistortionOscillator.phaseDistortionRange.clamp(newValue)
            guard phaseDistortion != clampedValue else { return }
            internalAU?.phaseDistortion.value = AUValue(clampedValue)
        }
    }

    /// Frequency offset in Hz.
    @objc open var detuningOffset: Double = defaultDetuningOffset {
        willSet {
            let clampedValue = AKPhaseDistortionOscillator.detuningOffsetRange.clamp(newValue)
            guard detuningOffset != clampedValue else { return }
            internalAU?.detuningOffset.value = AUValue(clampedValue)
        }
    }

    /// Frequency detuning multiplier
    @objc open var detuningMultiplier: Double = defaultDetuningMultiplier {
        willSet {
            let clampedValue = AKPhaseDistortionOscillator.detuningMultiplierRange.clamp(newValue)
            guard detuningMultiplier != clampedValue else { return }
            internalAU?.detuningMultiplier.value = AUValue(clampedValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open var isStarted: Bool {
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
    ///   - phaseDistortion: Amount of distortion, within the range [-1, 1]. 0 is no distortion.
    ///   - detuningOffset: Frequency offset in Hz.
    ///   - detuningMultiplier: Frequency detuning multiplier
    ///
    public init(
        waveform: AKTable,
        frequency: Double = defaultFrequency,
        amplitude: Double = defaultAmplitude,
        phaseDistortion: Double = defaultPhaseDistortion,
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
            self.phaseDistortion = phaseDistortion
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
