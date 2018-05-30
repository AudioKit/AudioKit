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
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createZitaReverbDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let predelay = AUParameterTree.createParameter(
            withIdentifier: "predelay",
            name: "Delay in ms before reverberation begins.",
            address: AUParameterAddress(0),
            min: Float(AKZitaReverb.predelayRange.lowerBound),
            max: Float(AKZitaReverb.predelayRange.upperBound),
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
            min: Float(AKZitaReverb.crossoverFrequencyRange.lowerBound),
            max: Float(AKZitaReverb.crossoverFrequencyRange.upperBound),
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
            min: Float(AKZitaReverb.lowReleaseTimeRange.lowerBound),
            max: Float(AKZitaReverb.lowReleaseTimeRange.upperBound),
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
            min: Float(AKZitaReverb.midReleaseTimeRange.lowerBound),
            max: Float(AKZitaReverb.midReleaseTimeRange.upperBound),
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
            min: Float(AKZitaReverb.dampingFrequencyRange.lowerBound),
            max: Float(AKZitaReverb.dampingFrequencyRange.upperBound),
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
            min: Float(AKZitaReverb.equalizerFrequency1Range.lowerBound),
            max: Float(AKZitaReverb.equalizerFrequency1Range.upperBound),
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
            min: Float(AKZitaReverb.equalizerLevel1Range.lowerBound),
            max: Float(AKZitaReverb.equalizerLevel1Range.upperBound),
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
            min: Float(AKZitaReverb.equalizerFrequency2Range.lowerBound),
            max: Float(AKZitaReverb.equalizerFrequency2Range.upperBound),
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
            min: Float(AKZitaReverb.equalizerLevel2Range.lowerBound),
            max: Float(AKZitaReverb.equalizerLevel2Range.upperBound),
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
            min: Float(AKZitaReverb.dryWetMixRange.lowerBound),
            max: Float(AKZitaReverb.dryWetMixRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [predelay, crossoverFrequency, lowReleaseTime, midReleaseTime, dampingFrequency, equalizerFrequency1, equalizerLevel1, equalizerFrequency2, equalizerLevel2, dryWetMix]))
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
