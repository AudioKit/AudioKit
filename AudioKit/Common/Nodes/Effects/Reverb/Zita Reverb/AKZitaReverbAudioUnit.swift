//
//  AKZitaReverbAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKZitaReverbAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKZitaReverbParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKZitaReverbParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var predelay: Double = AKZitaReverb.defaultPredelay {
        didSet { setParameter(.predelay, value: predelay) }
    }

    var crossoverFrequency: Double = AKZitaReverb.defaultCrossoverFrequency {
        didSet { setParameter(.crossoverFrequency, value: crossoverFrequency) }
    }

    var lowReleaseTime: Double = AKZitaReverb.defaultLowReleaseTime {
        didSet { setParameter(.lowReleaseTime, value: lowReleaseTime) }
    }

    var midReleaseTime: Double = AKZitaReverb.defaultMidReleaseTime {
        didSet { setParameter(.midReleaseTime, value: midReleaseTime) }
    }

    var dampingFrequency: Double = AKZitaReverb.defaultDampingFrequency {
        didSet { setParameter(.dampingFrequency, value: dampingFrequency) }
    }

    var equalizerFrequency1: Double = AKZitaReverb.defaultEqualizerFrequency1 {
        didSet { setParameter(.equalizerFrequency1, value: equalizerFrequency1) }
    }

    var equalizerLevel1: Double = AKZitaReverb.defaultEqualizerLevel1 {
        didSet { setParameter(.equalizerLevel1, value: equalizerLevel1) }
    }

    var equalizerFrequency2: Double = AKZitaReverb.defaultEqualizerFrequency2 {
        didSet { setParameter(.equalizerFrequency2, value: equalizerFrequency2) }
    }

    var equalizerLevel2: Double = AKZitaReverb.defaultEqualizerLevel2 {
        didSet { setParameter(.equalizerLevel2, value: equalizerLevel2) }
    }

    var dryWetMix: Double = AKZitaReverb.defaultDryWetMix {
        didSet { setParameter(.dryWetMix, value: dryWetMix) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createZitaReverbDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let predelay = AUParameter(
            identifier: "predelay",
            name: "Delay in ms before reverberation begins.",
            address: AKZitaReverbParameter.predelay.rawValue,
            range: AKZitaReverb.predelayRange,
            unit: .generic,
            flags: .default)
        let crossoverFrequency = AUParameter(
            identifier: "crossoverFrequency",
            name: "Crossover frequency separating low and middle frequencies (Hz).",
            address: AKZitaReverbParameter.crossoverFrequency.rawValue,
            range: AKZitaReverb.crossoverFrequencyRange,
            unit: .hertz,
            flags: .default)
        let lowReleaseTime = AUParameter(
            identifier: "lowReleaseTime",
            name: "Time (in seconds) to decay 60db in low-frequency band.",
            address: AKZitaReverbParameter.lowReleaseTime.rawValue,
            range: AKZitaReverb.lowReleaseTimeRange,
            unit: .seconds,
            flags: .default)
        let midReleaseTime = AUParameter(
            identifier: "midReleaseTime",
            name: "Time (in seconds) to decay 60db in mid-frequency band.",
            address: AKZitaReverbParameter.midReleaseTime.rawValue,
            range: AKZitaReverb.midReleaseTimeRange,
            unit: .seconds,
            flags: .default)
        let dampingFrequency = AUParameter(
            identifier: "dampingFrequency",
            name: "Frequency (Hz) at which the high-frequency T60 is half the middle-band's T60.",
            address: AKZitaReverbParameter.dampingFrequency.rawValue,
            range: AKZitaReverb.dampingFrequencyRange,
            unit: .hertz,
            flags: .default)
        let equalizerFrequency1 = AUParameter(
            identifier: "equalizerFrequency1",
            name: "Center frequency of second-order Regalia Mitra peaking equalizer section 1.",
            address: AKZitaReverbParameter.equalizerFrequency1.rawValue,
            range: AKZitaReverb.equalizerFrequency1Range,
            unit: .hertz,
            flags: .default)
        let equalizerLevel1 = AUParameter(
            identifier: "equalizerLevel1",
            name: "Peak level in dB of second-order Regalia-Mitra peaking equalizer section 1",
            address: AKZitaReverbParameter.equalizerLevel1.rawValue,
            range: AKZitaReverb.equalizerLevel1Range,
            unit: .generic,
            flags: .default)
        let equalizerFrequency2 = AUParameter(
            identifier: "equalizerFrequency2",
            name: "Center frequency of second-order Regalia Mitra peaking equalizer section 2.",
            address: AKZitaReverbParameter.equalizerFrequency2.rawValue,
            range: AKZitaReverb.equalizerFrequency2Range,
            unit: .hertz,
            flags: .default)
        let equalizerLevel2 = AUParameter(
            identifier: "equalizerLevel2",
            name: "Peak level in dB of second-order Regalia-Mitra peaking equalizer section 2",
            address: AKZitaReverbParameter.equalizerLevel2.rawValue,
            range: AKZitaReverb.equalizerLevel2Range,
            unit: .generic,
            flags: .default)
        let dryWetMix = AUParameter(
            identifier: "dryWetMix",
            name: "0 = all dry, 1 = all wet",
            address: AKZitaReverbParameter.dryWetMix.rawValue,
            range: AKZitaReverb.dryWetMixRange,
            unit: .generic,
            flags: .default)

        setParameterTree(AUParameterTree(children: [predelay, crossoverFrequency, lowReleaseTime, midReleaseTime, dampingFrequency, equalizerFrequency1, equalizerLevel1, equalizerFrequency2, equalizerLevel2, dryWetMix]))
        predelay.value = Float(AKZitaReverb.defaultPredelay)
        crossoverFrequency.value = Float(AKZitaReverb.defaultCrossoverFrequency)
        lowReleaseTime.value = Float(AKZitaReverb.defaultLowReleaseTime)
        midReleaseTime.value = Float(AKZitaReverb.defaultMidReleaseTime)
        dampingFrequency.value = Float(AKZitaReverb.defaultDampingFrequency)
        equalizerFrequency1.value = Float(AKZitaReverb.defaultEqualizerFrequency1)
        equalizerLevel1.value = Float(AKZitaReverb.defaultEqualizerLevel1)
        equalizerFrequency2.value = Float(AKZitaReverb.defaultEqualizerFrequency2)
        equalizerLevel2.value = Float(AKZitaReverb.defaultEqualizerLevel2)
        dryWetMix.value = Float(AKZitaReverb.defaultDryWetMix)
    }

    public override var canProcessInPlace: Bool { return true }

}
