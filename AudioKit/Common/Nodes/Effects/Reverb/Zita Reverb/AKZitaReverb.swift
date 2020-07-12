// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// 8 FDN stereo zitareverb algorithm, imported from Faust.
///
open class AKZitaReverb: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "zita")

    public typealias AKAudioUnitType = AKZitaReverbAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Delay in ms before reverberation begins.
    @Parameter public var predelay: AUValue

    /// Crossover frequency separating low and middle frequencies (Hz).
    @Parameter public var crossoverFrequency: AUValue

    /// Time (in seconds) to decay 60db in low-frequency band.
    @Parameter public var lowReleaseTime: AUValue

    /// Time (in seconds) to decay 60db in mid-frequency band.
    @Parameter public var midReleaseTime: AUValue

    /// Frequency (Hz) at which the high-frequency T60 is half the middle-band's T60.
    @Parameter public var dampingFrequency: AUValue

    /// Center frequency of second-order Regalia Mitra peaking equalizer section 1.
    @Parameter public var equalizerFrequency1: AUValue

    /// Peak level in dB of second-order Regalia-Mitra peaking equalizer section 1
    @Parameter public var equalizerLevel1: AUValue

    /// Center frequency of second-order Regalia Mitra peaking equalizer section 2.
    @Parameter public var equalizerFrequency2: AUValue

    /// Peak level in dB of second-order Regalia-Mitra peaking equalizer section 2
    @Parameter public var equalizerLevel2: AUValue

    /// 0 = all dry, 1 = all wet
    @Parameter public var dryWetMix: AUValue

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
        predelay: AUValue = 60.0,
        crossoverFrequency: AUValue = 200.0,
        lowReleaseTime: AUValue = 3.0,
        midReleaseTime: AUValue = 2.0,
        dampingFrequency: AUValue = 6_000.0,
        equalizerFrequency1: AUValue = 315.0,
        equalizerLevel1: AUValue = 0.0,
        equalizerFrequency2: AUValue = 1_500.0,
        equalizerLevel2: AUValue = 0.0,
        dryWetMix: AUValue = 1.0
        ) {
        super.init(avAudioNode: AVAudioNode())
        self.predelay = predelay
        self.crossoverFrequency = crossoverFrequency
        self.lowReleaseTime = lowReleaseTime
        self.midReleaseTime = midReleaseTime
        self.dampingFrequency = dampingFrequency
        self.equalizerFrequency1 = equalizerFrequency1
        self.equalizerLevel1 = equalizerLevel1
        self.equalizerFrequency2 = equalizerFrequency2
        self.equalizerLevel2 = equalizerLevel2
        self.dryWetMix = dryWetMix
        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            input?.connect(to: self)
        }
    }
}
