// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Casio-style phase distortion with "pivot point" on the X axis This module is
/// designed to emulate the classic phase distortion synthesis technique. From
/// the mid 90's. The technique reads the first and second halves of the ftbl at
/// different rates in order to warp the waveform. For example, pdhalf can
/// smoothly transition a sinewave into something approximating a sawtooth wave.
///
open class AKPWMOscillator: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKPWMOscillatorAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "pwmo")

    // MARK: - Properties

    public private(set) var internalAU: AKAudioUnitType?

    /// Lower and upper bounds for Frequency
    public static let frequencyRange = 0.0 ... 20_000.0

    /// Lower and upper bounds for Amplitude
    public static let amplitudeRange = 0.0 ... 10.0

    /// Lower and upper bounds for Pulse Width
    public static let pulseWidthRange = 0.0 ... 1.0

    /// Lower and upper bounds for Detuning Offset
    public static let detuningOffsetRange = -1_000.0 ... 1_000.0

    /// Lower and upper bounds for Detuning Multiplier
    public static let detuningMultiplierRange = 0.9 ... 1.11

    /// Initial value for Frequency
    public static let defaultFrequency = 440.0

    /// Initial value for Amplitude
    public static let defaultAmplitude = 1.0

    /// Initial value for Pulse Width
    public static let defaultPulseWidth = 0.5

    /// Initial value for Detuning Offset
    public static let defaultDetuningOffset = 0.0

    /// Initial value for Detuning Multiplier
    public static let defaultDetuningMultiplier = 1.0

    /// Frequency in cycles per second
    @objc open var frequency: Double = defaultFrequency {
        willSet {
            let clampedValue = AKPWMOscillator.frequencyRange.clamp(newValue)
            guard frequency != clampedValue else { return }
            internalAU?.frequency.value = AUValue(clampedValue)
        }
    }

    /// Output Amplitude.
    @objc open var amplitude: Double = defaultAmplitude {
        willSet {
            let clampedValue = AKPWMOscillator.amplitudeRange.clamp(newValue)
            guard amplitude != clampedValue else { return }
            internalAU?.amplitude.value = AUValue(clampedValue)
        }
    }

    /// Duty Cycle Width 0 - 1
    @objc open var pulseWidth: Double = defaultPulseWidth {
        willSet {
            let clampedValue = AKPWMOscillator.pulseWidthRange.clamp(newValue)
            guard pulseWidth != clampedValue else { return }
            internalAU?.pulseWidth.value = AUValue(clampedValue)
        }
    }

    /// Frequency offset in Hz.
    @objc open var detuningOffset: Double = defaultDetuningOffset {
        willSet {
            let clampedValue = AKPWMOscillator.detuningOffsetRange.clamp(newValue)
            guard detuningOffset != clampedValue else { return }
            internalAU?.detuningOffset.value = AUValue(clampedValue)
        }
    }

    /// Frequency detuning multiplier
    @objc open var detuningMultiplier: Double = defaultDetuningMultiplier {
        willSet {
            let clampedValue = AKPWMOscillator.detuningMultiplierRange.clamp(newValue)
            guard detuningMultiplier != clampedValue else { return }
            internalAU?.detuningMultiplier.value = AUValue(clampedValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    // MARK: - Initialization

    /// Initialize this oscillator node
    ///
    /// - Parameters:
    ///   - frequency: In cycles per second, or Hz.
    ///   - amplitude: Output amplitude
    ///   - pulseWidth: Duty cycle width (range 0-1).
    ///   - detuningOffset: Frequency offset in Hz.
    ///   - detuningMultiplier: Frequency detuning multiplier
    ///
    @objc public init(
        frequency: Double = 440,
        amplitude: Double = defaultAmplitude,
        pulseWidth: Double = defaultPulseWidth,
        detuningOffset: Double = defaultDetuningOffset,
        detuningMultiplier: Double = defaultDetuningMultiplier
    ) {
        super.init(avAudioNode: AVAudioNode())

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            self.frequency = frequency
            self.amplitude = amplitude
            self.pulseWidth = pulseWidth
            self.detuningOffset = detuningOffset
            self.detuningMultiplier = detuningMultiplier
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
