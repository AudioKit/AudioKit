// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// 8 FDN stereo zitareverb algorithm, imported from Faust.
///
public class AKZitaReverb: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "zita")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    public static let predelayDef = AKNodeParameterDef(
        identifier: "predelay",
        name: "Delay in ms before reverberation begins.",
        address: akGetParameterAddress("AKZitaReverbParameterPredelay"),
        range: 0.0 ... 200.0,
        unit: .generic,
        flags: .default)

    /// Delay in ms before reverberation begins.
    @Parameter public var predelay: AUValue

    public static let crossoverFrequencyDef = AKNodeParameterDef(
        identifier: "crossoverFrequency",
        name: "Crossover frequency separating low and middle frequencies (Hz).",
        address: akGetParameterAddress("AKZitaReverbParameterCrossoverFrequency"),
        range: 10.0 ... 1_000.0,
        unit: .hertz,
        flags: .default)

    /// Crossover frequency separating low and middle frequencies (Hz).
    @Parameter public var crossoverFrequency: AUValue

    public static let lowReleaseTimeDef = AKNodeParameterDef(
        identifier: "lowReleaseTime",
        name: "Time (in seconds) to decay 60db in low-frequency band.",
        address: akGetParameterAddress("AKZitaReverbParameterLowReleaseTime"),
        range: 0.0 ... 10.0,
        unit: .seconds,
        flags: .default)

    /// Time (in seconds) to decay 60db in low-frequency band.
    @Parameter public var lowReleaseTime: AUValue

    public static let midReleaseTimeDef = AKNodeParameterDef(
        identifier: "midReleaseTime",
        name: "Time (in seconds) to decay 60db in mid-frequency band.",
        address: akGetParameterAddress("AKZitaReverbParameterMidReleaseTime"),
        range: 0.0 ... 10.0,
        unit: .seconds,
        flags: .default)

    /// Time (in seconds) to decay 60db in mid-frequency band.
    @Parameter public var midReleaseTime: AUValue

    public static let dampingFrequencyDef = AKNodeParameterDef(
        identifier: "dampingFrequency",
        name: "Frequency (Hz) at which the high-frequency T60 is half the middle-band's T60.",
        address: akGetParameterAddress("AKZitaReverbParameterDampingFrequency"),
        range: 10.0 ... 22_050.0,
        unit: .hertz,
        flags: .default)

    /// Frequency (Hz) at which the high-frequency T60 is half the middle-band's T60.
    @Parameter public var dampingFrequency: AUValue

    public static let equalizerFrequency1Def = AKNodeParameterDef(
        identifier: "equalizerFrequency1",
        name: "Center frequency of second-order Regalia Mitra peaking equalizer section 1.",
        address: akGetParameterAddress("AKZitaReverbParameterEqualizerFrequency1"),
        range: 10.0 ... 1_000.0,
        unit: .hertz,
        flags: .default)

    /// Center frequency of second-order Regalia Mitra peaking equalizer section 1.
    @Parameter public var equalizerFrequency1: AUValue

    public static let equalizerLevel1Def = AKNodeParameterDef(
        identifier: "equalizerLevel1",
        name: "Peak level in dB of second-order Regalia-Mitra peaking equalizer section 1",
        address: akGetParameterAddress("AKZitaReverbParameterEqualizerLevel1"),
        range: -100.0 ... 10.0,
        unit: .generic,
        flags: .default)

    /// Peak level in dB of second-order Regalia-Mitra peaking equalizer section 1
    @Parameter public var equalizerLevel1: AUValue

    public static let equalizerFrequency2Def = AKNodeParameterDef(
        identifier: "equalizerFrequency2",
        name: "Center frequency of second-order Regalia Mitra peaking equalizer section 2.",
        address: akGetParameterAddress("AKZitaReverbParameterEqualizerFrequency2"),
        range: 10.0 ... 22_050.0,
        unit: .hertz,
        flags: .default)

    /// Center frequency of second-order Regalia Mitra peaking equalizer section 2.
    @Parameter public var equalizerFrequency2: AUValue

    public static let equalizerLevel2Def = AKNodeParameterDef(
        identifier: "equalizerLevel2",
        name: "Peak level in dB of second-order Regalia-Mitra peaking equalizer section 2",
        address: akGetParameterAddress("AKZitaReverbParameterEqualizerLevel2"),
        range: -100.0 ... 10.0,
        unit: .generic,
        flags: .default)

    /// Peak level in dB of second-order Regalia-Mitra peaking equalizer section 2
    @Parameter public var equalizerLevel2: AUValue

    public static let dryWetMixDef = AKNodeParameterDef(
        identifier: "dryWetMix",
        name: "0 = all dry, 1 = all wet",
        address: akGetParameterAddress("AKZitaReverbParameterDryWetMix"),
        range: 0.0 ... 1.0,
        unit: .generic,
        flags: .default)

    /// 0 = all dry, 1 = all wet
    @Parameter public var dryWetMix: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKZitaReverb.predelayDef,
             AKZitaReverb.crossoverFrequencyDef,
             AKZitaReverb.lowReleaseTimeDef,
             AKZitaReverb.midReleaseTimeDef,
             AKZitaReverb.dampingFrequencyDef,
             AKZitaReverb.equalizerFrequency1Def,
             AKZitaReverb.equalizerLevel1Def,
             AKZitaReverb.equalizerFrequency2Def,
             AKZitaReverb.equalizerLevel2Def,
             AKZitaReverb.dryWetMixDef]
        }

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKZitaReverbDSP")
        }
    }

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
        }

        if let input = input {
            connections.append(input)
        }
    }
}
