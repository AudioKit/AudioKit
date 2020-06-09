// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Classic FM Synthesis audio generation.
///
open class AKFMOscillator: AKNode, AKToggleable, AKComponent, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "fosc")

    public typealias AKAudioUnitType = AKFMOscillatorAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    fileprivate var waveform: AKTable?

    /// Lower and upper bounds for Base Frequency
    public static let baseFrequencyRange: ClosedRange<AUValue> = 0.0 ... 20_000.0

    /// Lower and upper bounds for Carrier Multiplier
    public static let carrierMultiplierRange: ClosedRange<AUValue> = 0.0 ... 1_000.0

    /// Lower and upper bounds for Modulating Multiplier
    public static let modulatingMultiplierRange: ClosedRange<AUValue> = 0.0 ... 1_000.0

    /// Lower and upper bounds for Modulation Index
    public static let modulationIndexRange: ClosedRange<AUValue> = 0.0 ... 1_000.0

    /// Lower and upper bounds for Amplitude
    public static let amplitudeRange: ClosedRange<AUValue> = 0.0 ... 10.0

    /// Initial value for Base Frequency
    public static let defaultBaseFrequency: AUValue = 440.0

    /// Initial value for Carrier Multiplier
    public static let defaultCarrierMultiplier: AUValue = 1.0

    /// Initial value for Modulating Multiplier
    public static let defaultModulatingMultiplier: AUValue = 1.0

    /// Initial value for Modulation Index
    public static let defaultModulationIndex: AUValue = 1.0

    /// Initial value for Amplitude
    public static let defaultAmplitude: AUValue = 1.0

    /// In cycles per second, or Hz, this is the common denominator for the carrier and modulating frequencies.
    public let baseFrequency = AKNodeParameter(identifier: "baseFrequency")

    /// This multiplied by the baseFrequency gives the carrier frequency.
    public let carrierMultiplier = AKNodeParameter(identifier: "carrierMultiplier")

    /// This multiplied by the baseFrequency gives the modulating frequency.
    public let modulatingMultiplier = AKNodeParameter(identifier: "modulatingMultiplier")

    /// This multiplied by the modulating frequency gives the modulation amplitude.
    public let modulationIndex = AKNodeParameter(identifier: "modulationIndex")

    /// Output Amplitude.
    public let amplitude = AKNodeParameter(identifier: "amplitude")

    // MARK: - Initialization

    /// Initialize this oscillator node
    ///
    /// - Parameters:
    ///   - waveform: The waveform of oscillation
    ///   - baseFrequency: In cycles per second, the common denominator for the carrier and modulating frequencies.
    ///   - carrierMultiplier: This multiplied by the baseFrequency gives the carrier frequency.
    ///   - modulatingMultiplier: This multiplied by the baseFrequency gives the modulating frequency.
    ///   - modulationIndex: This multiplied by the modulating frequency gives the modulation amplitude.
    ///   - amplitude: Output Amplitude.
    ///
    public init(
        waveform: AKTable = AKTable(.sine),
        baseFrequency: AUValue = defaultBaseFrequency,
        carrierMultiplier: AUValue = defaultCarrierMultiplier,
        modulatingMultiplier: AUValue = defaultModulatingMultiplier,
        modulationIndex: AUValue = defaultModulationIndex,
        amplitude: AUValue = defaultAmplitude
    ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.waveform = waveform
            self.baseFrequency.associate(with: self.internalAU, value: baseFrequency)
            self.carrierMultiplier.associate(with: self.internalAU, value: carrierMultiplier)
            self.modulatingMultiplier.associate(with: self.internalAU, value: modulatingMultiplier)
            self.modulationIndex.associate(with: self.internalAU, value: modulationIndex)
            self.amplitude.associate(with: self.internalAU, value: amplitude)

            self.internalAU?.setWavetable(waveform.content)
        }

    }
}
