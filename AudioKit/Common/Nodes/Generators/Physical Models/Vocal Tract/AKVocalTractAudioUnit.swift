//
//  AKVocalTractAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKVocalTractAudioUnit: AKGeneratorAudioUnitBase {

    func setParameter(_ address: AKVocalTractParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKVocalTractParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var frequency: Double = AKVocalTract.defaultFrequency {
        didSet { setParameter(.frequency, value: frequency) }
    }

    var tonguePosition: Double = AKVocalTract.defaultTonguePosition {
        didSet { setParameter(.tonguePosition, value: tonguePosition) }
    }

    var tongueDiameter: Double = AKVocalTract.defaultTongueDiameter {
        didSet { setParameter(.tongueDiameter, value: tongueDiameter) }
    }

    var tenseness: Double = AKVocalTract.defaultTenseness {
        didSet { setParameter(.tenseness, value: tenseness) }
    }

    var nasality: Double = AKVocalTract.defaultNasality {
        didSet { setParameter(.nasality, value: nasality) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createVocalTractDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let frequency = AUParameter(
            identifier: "frequency",
            name: "Glottal frequency.",
            address: AKVocalTractParameter.frequency.rawValue,
            range: AKVocalTract.frequencyRange,
            unit: .hertz,
            flags: .default)
        let tonguePosition = AUParameter(
            identifier: "tonguePosition",
            name: "Tongue position (0-1)",
            address: AKVocalTractParameter.tonguePosition.rawValue,
            range: AKVocalTract.tonguePositionRange,
            unit: .generic,
            flags: .default)
        let tongueDiameter = AUParameter(
            identifier: "tongueDiameter",
            name: "Tongue diameter (0-1)",
            address: AKVocalTractParameter.tongueDiameter.rawValue,
            range: AKVocalTract.tongueDiameterRange,
            unit: .generic,
            flags: .default)
        let tenseness = AUParameter(
            identifier: "tenseness",
            name: "Vocal tenseness. 0 = all breath. 1=fully saturated.",
            address: AKVocalTractParameter.tenseness.rawValue,
            range: AKVocalTract.tensenessRange,
            unit: .generic,
            flags: .default)
        let nasality = AUParameter(
            identifier: "nasality",
            name: "Sets the velum size. Larger values of this creates more nasally sounds.",
            address: AKVocalTractParameter.nasality.rawValue,
            range: AKVocalTract.nasalityRange,
            unit: .generic,
            flags: .default)

        setParameterTree(AUParameterTree(children: [frequency, tonguePosition, tongueDiameter, tenseness, nasality]))
        frequency.value = Float(AKVocalTract.defaultFrequency)
        tonguePosition.value = Float(AKVocalTract.defaultTonguePosition)
        tongueDiameter.value = Float(AKVocalTract.defaultTongueDiameter)
        tenseness.value = Float(AKVocalTract.defaultTenseness)
        nasality.value = Float(AKVocalTract.defaultNasality)
    }

    public override var canProcessInPlace: Bool { return true }

}
