// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKZitaReverbAudioUnit: AKAudioUnitBase {

    let predelay = AUParameter(
        identifier: "predelay",
        name: "Delay in ms before reverberation begins.",
        address: AKZitaReverbParameter.predelay.rawValue,
        range: 0.0 ... 200.0,
        unit: .generic,
        flags: .default)

    let crossoverFrequency = AUParameter(
        identifier: "crossoverFrequency",
        name: "Crossover frequency separating low and middle frequencies (Hz).",
        address: AKZitaReverbParameter.crossoverFrequency.rawValue,
        range: 10.0 ... 1_000.0,
        unit: .hertz,
        flags: .default)

    let lowReleaseTime = AUParameter(
        identifier: "lowReleaseTime",
        name: "Time (in seconds) to decay 60db in low-frequency band.",
        address: AKZitaReverbParameter.lowReleaseTime.rawValue,
        range: 0.0 ... 10.0,
        unit: .seconds,
        flags: .default)

    let midReleaseTime = AUParameter(
        identifier: "midReleaseTime",
        name: "Time (in seconds) to decay 60db in mid-frequency band.",
        address: AKZitaReverbParameter.midReleaseTime.rawValue,
        range: 0.0 ... 10.0,
        unit: .seconds,
        flags: .default)

    let dampingFrequency = AUParameter(
        identifier: "dampingFrequency",
        name: "Frequency (Hz) at which the high-frequency T60 is half the middle-band's T60.",
        address: AKZitaReverbParameter.dampingFrequency.rawValue,
        range: 10.0 ... 22_050.0,
        unit: .hertz,
        flags: .default)

    let equalizerFrequency1 = AUParameter(
        identifier: "equalizerFrequency1",
        name: "Center frequency of second-order Regalia Mitra peaking equalizer section 1.",
        address: AKZitaReverbParameter.equalizerFrequency1.rawValue,
        range: 10.0 ... 1_000.0,
        unit: .hertz,
        flags: .default)

    let equalizerLevel1 = AUParameter(
        identifier: "equalizerLevel1",
        name: "Peak level in dB of second-order Regalia-Mitra peaking equalizer section 1",
        address: AKZitaReverbParameter.equalizerLevel1.rawValue,
        range: -100.0 ... 10.0,
        unit: .generic,
        flags: .default)

    let equalizerFrequency2 = AUParameter(
        identifier: "equalizerFrequency2",
        name: "Center frequency of second-order Regalia Mitra peaking equalizer section 2.",
        address: AKZitaReverbParameter.equalizerFrequency2.rawValue,
        range: 10.0 ... 22_050.0,
        unit: .hertz,
        flags: .default)

    let equalizerLevel2 = AUParameter(
        identifier: "equalizerLevel2",
        name: "Peak level in dB of second-order Regalia-Mitra peaking equalizer section 2",
        address: AKZitaReverbParameter.equalizerLevel2.rawValue,
        range: -100.0 ... 10.0,
        unit: .generic,
        flags: .default)

    let dryWetMix = AUParameter(
        identifier: "dryWetMix",
        name: "0 = all dry, 1 = all wet",
        address: AKZitaReverbParameter.dryWetMix.rawValue,
        range: 0.0 ... 1.0,
        unit: .generic,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createZitaReverbDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [predelay,
                                                                  crossoverFrequency,
                                                                  lowReleaseTime,
                                                                  midReleaseTime,
                                                                  dampingFrequency,
                                                                  equalizerFrequency1,
                                                                  equalizerLevel1,
                                                                  equalizerFrequency2,
                                                                  equalizerLevel2,
                                                                  dryWetMix])
    }
}
