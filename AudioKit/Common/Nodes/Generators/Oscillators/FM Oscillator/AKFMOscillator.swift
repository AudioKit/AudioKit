// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Classic FM Synthesis audio generation.
///
open class AKFMOscillator: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(generator: "fosc")

    public typealias AKAudioUnitType = AKFMOscillatorAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    fileprivate var waveform: AKTable?

    /// In cycles per second, or Hz, this is the common denominator for the carrier and modulating frequencies.
    @Parameter public var baseFrequency: AUValue

    /// This multiplied by the baseFrequency gives the carrier frequency.
    @Parameter public var carrierMultiplier: AUValue

    /// This multiplied by the baseFrequency gives the modulating frequency.
    @Parameter public var modulatingMultiplier: AUValue

    /// This multiplied by the modulating frequency gives the modulation amplitude.
    @Parameter public var modulationIndex: AUValue

    /// Output Amplitude.
    @Parameter public var amplitude: AUValue

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
        baseFrequency: AUValue = 440.0,
        carrierMultiplier: AUValue = 1.0,
        modulatingMultiplier: AUValue = 1.0,
        modulationIndex: AUValue = 1.0,
        amplitude: AUValue = 1.0
    ) {
        super.init(avAudioNode: AVAudioNode())

        self.waveform = waveform
        self.baseFrequency = baseFrequency
        self.carrierMultiplier = carrierMultiplier
        self.modulatingMultiplier = modulatingMultiplier
        self.modulationIndex = modulationIndex
        self.amplitude = amplitude

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.internalAU?.setWavetable(waveform.content)
        }

    }
}
