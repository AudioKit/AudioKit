// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// 8 FDN stereo zitareverb algorithm, imported from Faust.
///
open class AKZitaReverb: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "zita")

    public typealias AKAudioUnitType = AKZitaReverbAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Lower and upper bounds for Predelay
    public static let predelayRange: ClosedRange<AUValue> = 0.0 ... 200.0

    /// Lower and upper bounds for Crossover Frequency
    public static let crossoverFrequencyRange: ClosedRange<AUValue> = 10.0 ... 1_000.0

    /// Lower and upper bounds for Low Release Time
    public static let lowReleaseTimeRange: ClosedRange<AUValue> = 0.0 ... 10.0

    /// Lower and upper bounds for Mid Release Time
    public static let midReleaseTimeRange: ClosedRange<AUValue> = 0.0 ... 10.0

    /// Lower and upper bounds for Damping Frequency
    public static let dampingFrequencyRange: ClosedRange<AUValue> = 10.0 ... 22_050.0

    /// Lower and upper bounds for Equalizer Frequency1
    public static let equalizerFrequency1Range: ClosedRange<AUValue> = 10.0 ... 1_000.0

    /// Lower and upper bounds for Equalizer Level1
    public static let equalizerLevel1Range: ClosedRange<AUValue> = -100.0 ... 10.0

    /// Lower and upper bounds for Equalizer Frequency2
    public static let equalizerFrequency2Range: ClosedRange<AUValue> = 10.0 ... 22_050.0

    /// Lower and upper bounds for Equalizer Level2
    public static let equalizerLevel2Range: ClosedRange<AUValue> = -100.0 ... 10.0

    /// Lower and upper bounds for Dry Wet Mix
    public static let dryWetMixRange: ClosedRange<AUValue> = 0.0 ... 1.0

    /// Initial value for Predelay
    public static let defaultPredelay: AUValue = 60.0

    /// Initial value for Crossover Frequency
    public static let defaultCrossoverFrequency: AUValue = 200.0

    /// Initial value for Low Release Time
    public static let defaultLowReleaseTime: AUValue = 3.0

    /// Initial value for Mid Release Time
    public static let defaultMidReleaseTime: AUValue = 2.0

    /// Initial value for Damping Frequency
    public static let defaultDampingFrequency: AUValue = 6_000.0

    /// Initial value for Equalizer Frequency1
    public static let defaultEqualizerFrequency1: AUValue = 315.0

    /// Initial value for Equalizer Level1
    public static let defaultEqualizerLevel1: AUValue = 0.0

    /// Initial value for Equalizer Frequency2
    public static let defaultEqualizerFrequency2: AUValue = 1_500.0

    /// Initial value for Equalizer Level2
    public static let defaultEqualizerLevel2: AUValue = 0.0

    /// Initial value for Dry Wet Mix
    public static let defaultDryWetMix: AUValue = 1.0

    /// Delay in ms before reverberation begins.
    public let predelay = AKNodeParameter(identifier: "predelay")

    /// Crossover frequency separating low and middle frequencies (Hz).
    public let crossoverFrequency = AKNodeParameter(identifier: "crossoverFrequency")

    /// Time (in seconds) to decay 60db in low-frequency band.
    public let lowReleaseTime = AKNodeParameter(identifier: "lowReleaseTime")

    /// Time (in seconds) to decay 60db in mid-frequency band.
    public let midReleaseTime = AKNodeParameter(identifier: "midReleaseTime")

    /// Frequency (Hz) at which the high-frequency T60 is half the middle-band's T60.
    public let dampingFrequency = AKNodeParameter(identifier: "dampingFrequency")

    /// Center frequency of second-order Regalia Mitra peaking equalizer section 1.
    public let equalizerFrequency1 = AKNodeParameter(identifier: "equalizerFrequency1")

    /// Peak level in dB of second-order Regalia-Mitra peaking equalizer section 1
    public let equalizerLevel1 = AKNodeParameter(identifier: "equalizerLevel1")

    /// Center frequency of second-order Regalia Mitra peaking equalizer section 2.
    public let equalizerFrequency2 = AKNodeParameter(identifier: "equalizerFrequency2")

    /// Peak level in dB of second-order Regalia-Mitra peaking equalizer section 2
    public let equalizerLevel2 = AKNodeParameter(identifier: "equalizerLevel2")

    /// 0 = all dry, 1 = all wet
    public let dryWetMix = AKNodeParameter(identifier: "dryWetMix")

    // MARK: - Initialization

    /// Initialize this reverb node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - predelay: Delay in ms before reverberation begins.
    ///   - crossoverFrequency: Crossover frequency separating low and middle frequencies (Hz).
    ///   - lowReleaseTime: Time (in seconds) to decay 60db in low-frequency band.
    ///   - midReleaseTime: Time (in seconds) to decay 60db in mid-frequency band.
    ///   - dampingFrequency: Frequency (Hz) at which the high-frequency T60 is half the middle-band's T60.
    ///   - equalizerFrequency1: Center frequency of second-order Regalia Mitra peaking equalizer section 1.
    ///   - equalizerLevel1: Peak level in dB of second-order Regalia-Mitra peaking equalizer section 1
    ///   - equalizerFrequency2: Center frequency of second-order Regalia Mitra peaking equalizer section 2.
    ///   - equalizerLevel2: Peak level in dB of second-order Regalia-Mitra peaking equalizer section 2
    ///   - dryWetMix: 0 = all dry, 1 = all wet
    ///
    public init(
        _ input: AKNode? = nil,
        predelay: AUValue = defaultPredelay,
        crossoverFrequency: AUValue = defaultCrossoverFrequency,
        lowReleaseTime: AUValue = defaultLowReleaseTime,
        midReleaseTime: AUValue = defaultMidReleaseTime,
        dampingFrequency: AUValue = defaultDampingFrequency,
        equalizerFrequency1: AUValue = defaultEqualizerFrequency1,
        equalizerLevel1: AUValue = defaultEqualizerLevel1,
        equalizerFrequency2: AUValue = defaultEqualizerFrequency2,
        equalizerLevel2: AUValue = defaultEqualizerLevel2,
        dryWetMix: AUValue = defaultDryWetMix
        ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.predelay.associate(with: self.internalAU, value: predelay)
            self.crossoverFrequency.associate(with: self.internalAU, value: crossoverFrequency)
            self.lowReleaseTime.associate(with: self.internalAU, value: lowReleaseTime)
            self.midReleaseTime.associate(with: self.internalAU, value: midReleaseTime)
            self.dampingFrequency.associate(with: self.internalAU, value: dampingFrequency)
            self.equalizerFrequency1.associate(with: self.internalAU, value: equalizerFrequency1)
            self.equalizerLevel1.associate(with: self.internalAU, value: equalizerLevel1)
            self.equalizerFrequency2.associate(with: self.internalAU, value: equalizerFrequency2)
            self.equalizerLevel2.associate(with: self.internalAU, value: equalizerLevel2)
            self.dryWetMix.associate(with: self.internalAU, value: dryWetMix)

            input?.connect(to: self)
        }
    }
}
