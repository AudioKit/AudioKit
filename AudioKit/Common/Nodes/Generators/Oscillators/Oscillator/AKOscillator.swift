// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Reads from the table sequentially and repeatedly at given frequency. Linear
/// interpolation is applied for table look up from internal phase values.
///
open class AKOscillator: AKNode, AKToggleable, AKComponent, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "oscl")

    public typealias AKAudioUnitType = AKOscillatorAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    fileprivate var waveform: AKTable?

    /// Lower and upper bounds for Frequency
    public static let frequencyRange: ClosedRange<AUValue> = 0.0 ... 20_000.0

    /// Lower and upper bounds for Amplitude
    public static let amplitudeRange: ClosedRange<AUValue> = 0.0 ... 10.0

    /// Lower and upper bounds for Detuning Offset
    public static let detuningOffsetRange: ClosedRange<AUValue> = -1_000.0 ... 1_000.0

    /// Lower and upper bounds for Detuning Multiplier
    public static let detuningMultiplierRange: ClosedRange<AUValue> = 0.9 ... 1.11

    /// Initial value for Frequency
    public static let defaultFrequency: AUValue = 440.0

    /// Initial value for Amplitude
    public static let defaultAmplitude: AUValue = 1.0

    /// Initial value for Detuning Offset
    public static let defaultDetuningOffset: AUValue = 0.0

    /// Initial value for Detuning Multiplier
    public static let defaultDetuningMultiplier: AUValue = 1.0

    /// Frequency in cycles per second
    @Parameter public var frequency: AUValue

    /// Output Amplitude.
    @Parameter public var amplitude: AUValue

    /// Frequency offset in Hz.
    @Parameter public var detuningOffset: AUValue

    /// Frequency detuning multiplier
    @Parameter public var detuningMultiplier: AUValue

    // MARK: - Initialization

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
        waveform: AKTable = AKTable(.sine),
        frequency: AUValue = defaultFrequency,
        amplitude: AUValue = defaultAmplitude,
        detuningOffset: AUValue = defaultDetuningOffset,
        detuningMultiplier: AUValue = defaultDetuningMultiplier
    ) {
        super.init(avAudioNode: AVAudioNode())

        self.waveform = waveform
        self.frequency = frequency
        self.amplitude = amplitude
        self.detuningOffset = detuningOffset
        self.detuningMultiplier = detuningMultiplier

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.internalAU?.setWavetable(waveform.content)
        }

    }
}
