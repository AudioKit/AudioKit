// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Casio-style phase distortion with "pivot point" on the X axis This module is
/// designed to emulate the classic phase distortion synthesis technique. From
/// the mid 90's. The technique reads the first and second halves of the ftbl at
/// different rates in order to warp the waveform. For example, pdhalf can
/// smoothly transition a sinewave into something approximating a sawtooth wave.
///
open class AKPWMOscillator: AKNode, AKToggleable, AKComponent, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "pwmo")

    public typealias AKAudioUnitType = AKPWMOscillatorAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Lower and upper bounds for Frequency
    public static let frequencyRange: ClosedRange<AUValue> = 0.0 ... 20_000.0

    /// Lower and upper bounds for Amplitude
    public static let amplitudeRange: ClosedRange<AUValue> = 0.0 ... 10.0

    /// Lower and upper bounds for Pulse Width
    public static let pulseWidthRange: ClosedRange<AUValue> = 0.0 ... 1.0

    /// Lower and upper bounds for Detuning Offset
    public static let detuningOffsetRange: ClosedRange<AUValue> = -1_000.0 ... 1_000.0

    /// Lower and upper bounds for Detuning Multiplier
    public static let detuningMultiplierRange: ClosedRange<AUValue> = 0.9 ... 1.11

    /// Initial value for Frequency
    public static let defaultFrequency: AUValue = 440.0

    /// Initial value for Amplitude
    public static let defaultAmplitude: AUValue = 1.0

    /// Initial value for Pulse Width
    public static let defaultPulseWidth: AUValue = 0.5

    /// Initial value for Detuning Offset
    public static let defaultDetuningOffset: AUValue = 0.0

    /// Initial value for Detuning Multiplier
    public static let defaultDetuningMultiplier: AUValue = 1.0

    /// Frequency in cycles per second
    public let frequency = AKNodeParameter(identifier: "frequency")

    /// Output Amplitude.
    public let amplitude = AKNodeParameter(identifier: "amplitude")

    /// Duty Cycle Width 0 - 1
    public let pulseWidth = AKNodeParameter(identifier: "pulseWidth")

    /// Frequency offset in Hz.
    public let detuningOffset = AKNodeParameter(identifier: "detuningOffset")

    /// Frequency detuning multiplier
    public let detuningMultiplier = AKNodeParameter(identifier: "detuningMultiplier")

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
    public init(
        frequency: AUValue = defaultFrequency,
        amplitude: AUValue = defaultAmplitude,
        pulseWidth: AUValue = defaultPulseWidth,
        detuningOffset: AUValue = defaultDetuningOffset,
        detuningMultiplier: AUValue = defaultDetuningMultiplier
    ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.frequency.associate(with: self.internalAU, value: frequency)
            self.amplitude.associate(with: self.internalAU, value: amplitude)
            self.pulseWidth.associate(with: self.internalAU, value: pulseWidth)
            self.detuningOffset.associate(with: self.internalAU, value: detuningOffset)
            self.detuningMultiplier.associate(with: self.internalAU, value: detuningMultiplier)
        }
    }
}
