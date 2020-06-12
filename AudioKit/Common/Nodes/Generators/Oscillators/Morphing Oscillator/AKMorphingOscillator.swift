// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// This is an oscillator with linear interpolation that is capable of morphing
/// between an arbitrary number of wavetables.
///
open class AKMorphingOscillator: AKNode, AKToggleable, AKComponent, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "morf")

    public typealias AKAudioUnitType = AKMorphingOscillatorAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    fileprivate var waveformArray = [AKTable]()

    /// Lower and upper bounds for Frequency
    public static let frequencyRange: ClosedRange<AUValue> = 0.0 ... 22_050.0

    /// Lower and upper bounds for Amplitude
    public static let amplitudeRange: ClosedRange<AUValue> = 0.0 ... 1.0

    /// Lower and upper bounds for Index
    public static let indexRange: ClosedRange<AUValue> = 0.0 ... 3.0

    /// Lower and upper bounds for Detuning Offset
    public static let detuningOffsetRange: ClosedRange<AUValue> = -1_000.0 ... 1_000.0

    /// Lower and upper bounds for Detuning Multiplier
    public static let detuningMultiplierRange: ClosedRange<AUValue> = 0.9 ... 1.11

    /// Initial value for Frequency
    public static let defaultFrequency: AUValue = 440

    /// Initial value for Amplitude
    public static let defaultAmplitude: AUValue = 0.5

    /// Initial value for Index
    public static let defaultIndex: AUValue = 0.0

    /// Initial value for Detuning Offset
    public static let defaultDetuningOffset: AUValue = 0

    /// Initial value for Detuning Multiplier
    public static let defaultDetuningMultiplier: AUValue = 1

    /// Frequency (in Hz)
    public let frequency = AKNodeParameter(identifier: "frequency")

    /// Amplitude (typically a value between 0 and 1).
    public let amplitude = AKNodeParameter(identifier: "amplitude")

    /// Index of the wavetable to use (fractional are okay).
    public let index = AKNodeParameter(identifier: "index")

    /// Frequency offset in Hz.
    public let detuningOffset = AKNodeParameter(identifier: "detuningOffset")

    /// Frequency detuning multiplier
    public let detuningMultiplier = AKNodeParameter(identifier: "detuningMultiplier")

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
    ///
    public init(
        waveformArray: [AKTable] = [AKTable(.triangle), AKTable(.square), AKTable(.sine), AKTable(.sawtooth)],
        frequency: AUValue = defaultFrequency,
        amplitude: AUValue = defaultAmplitude,
        index: AUValue = defaultIndex,
        detuningOffset: AUValue = defaultDetuningOffset,
        detuningMultiplier: AUValue = defaultDetuningMultiplier
    ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.waveformArray = waveformArray
            self.frequency.associate(with: self.internalAU, value: frequency)
            self.amplitude.associate(with: self.internalAU, value: amplitude)
            self.index.associate(with: self.internalAU, value: index)
            self.detuningOffset.associate(with: self.internalAU, value: detuningOffset)
            self.detuningMultiplier.associate(with: self.internalAU, value: detuningMultiplier)

            for (i, waveform) in waveformArray.enumerated() {
                self.internalAU?.setWavetable(waveform.content, index: i)
            }
        }

    }
}
