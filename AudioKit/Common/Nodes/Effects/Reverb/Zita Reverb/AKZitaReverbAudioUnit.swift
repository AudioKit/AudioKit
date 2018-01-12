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
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKZitaReverbParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    var predelay: Double = 60.0 {
        didSet { setParameter(.predelay, value: predelay) }
    }
    var crossoverFrequency: Double = 200.0 {
        didSet { setParameter(.crossoverFrequency, value: crossoverFrequency) }
    }
    var lowReleaseTime: Double = 3.0 {
        didSet { setParameter(.lowReleaseTime, value: lowReleaseTime) }
    }
    var midReleaseTime: Double = 2.0 {
        didSet { setParameter(.midReleaseTime, value: midReleaseTime) }
    }
    var dampingFrequency: Double = 6_000.0 {
        didSet { setParameter(.dampingFrequency, value: dampingFrequency) }
    }
    var equalizerFrequency1: Double = 315.0 {
        didSet { setParameter(.equalizerFrequency1, value: equalizerFrequency1) }
    }
    var equalizerLevel1: Double = 0.0 {
        didSet { setParameter(.equalizerLevel1, value: equalizerLevel1) }
    }
    var equalizerFrequency2: Double = 1_500.0 {
        didSet { setParameter(.equalizerFrequency2, value: equalizerFrequency2) }
    }
    var equalizerLevel2: Double = 0.0 {
        didSet { setParameter(.equalizerLevel2, value: equalizerLevel2) }
    }
    var dryWetMix: Double = 1.0 {
        didSet { setParameter(.dryWetMix, value: dryWetMix) }
    }

    var rampTime: Double = 0.0 {
        didSet { setParameter(.rampTime, value: rampTime) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createZitaReverbDSP(Int32(count), sampleRate)
    }

    override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let predelay = AUParameterTree.createParameter(
            withIdentifier: "predelay",
            name: "Delay in ms before reverberation begins.",
            address: AUParameterAddress(0),
            min: 0.0,
            max: 200.0,
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let crossoverFrequency = AUParameterTree.createParameter(
            withIdentifier: "crossoverFrequency",
            name: "Crossover frequency separating low and middle frequencies (Hz).",
            address: AUParameterAddress(1),
            min: 10.0,
            max: 1_000.0,
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let lowReleaseTime = AUParameterTree.createParameter(
            withIdentifier: "lowReleaseTime",
            name: "Time (in seconds) to decay 60db in low-frequency band.",
            address: AUParameterAddress(2),
            min: 0.0,
            max: 10.0,
            unit: .seconds,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let midReleaseTime = AUParameterTree.createParameter(
            withIdentifier: "midReleaseTime",
            name: "Time (in seconds) to decay 60db in mid-frequency band.",
            address: AUParameterAddress(3),
            min: 0.0,
            max: 10.0,
            unit: .seconds,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let dampingFrequency = AUParameterTree.createParameter(
            withIdentifier: "dampingFrequency",
            name: "Frequency (Hz) at which the high-frequency T60 is half the middle-band's T60.",
            address: AUParameterAddress(4),
            min: 10.0,
            max: 22_050.0,
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let equalizerFrequency1 = AUParameterTree.createParameter(
            withIdentifier: "equalizerFrequency1",
            name: "Center frequency of second-order Regalia Mitra peaking equalizer section 1.",
            address: AUParameterAddress(5),
            min: 10.0,
            max: 1_000.0,
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let equalizerLevel1 = AUParameterTree.createParameter(
            withIdentifier: "equalizerLevel1",
            name: "Peak level in dB of second-order Regalia-Mitra peaking equalizer section 1",
            address: AUParameterAddress(6),
            min: -100.0,
            max: 10.0,
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let equalizerFrequency2 = AUParameterTree.createParameter(
            withIdentifier: "equalizerFrequency2",
            name: "Center frequency of second-order Regalia Mitra peaking equalizer section 2.",
            address: AUParameterAddress(7),
            min: 10.0,
            max: 22_050.0,
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let equalizerLevel2 = AUParameterTree.createParameter(
            withIdentifier: "equalizerLevel2",
            name: "Peak level in dB of second-order Regalia-Mitra peaking equalizer section 2",
            address: AUParameterAddress(8),
            min: -100.0,
            max: 10.0,
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let dryWetMix = AUParameterTree.createParameter(
            withIdentifier: "dryWetMix",
            name: "0 = all dry, 1 = all wet",
            address: AUParameterAddress(9),
            min: 0.0,
            max: 1.0,
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [predelay, crossoverFrequency, lowReleaseTime, midReleaseTime, dampingFrequency, equalizerFrequency1, equalizerLevel1, equalizerFrequency2, equalizerLevel2, dryWetMix]))
        predelay.value = 60.0
        crossoverFrequency.value = 200.0
        lowReleaseTime.value = 3.0
        midReleaseTime.value = 2.0
        dampingFrequency.value = 6_000.0
        equalizerFrequency1.value = 315.0
        equalizerLevel1.value = 0.0
        equalizerFrequency2.value = 1_500.0
        equalizerLevel2.value = 0.0
        dryWetMix.value = 1.0
    }

    public override var canProcessInPlace: Bool { get { return true; }}

}
