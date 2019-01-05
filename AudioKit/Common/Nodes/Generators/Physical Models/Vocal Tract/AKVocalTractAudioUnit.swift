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

        let frequency = AUParameterTree.createParameter(
            identifier: "frequency",
            name: "Glottal frequency.",
            address: AKVocalTractParameter.frequency.rawValue,
            min: Float(AKVocalTract.frequencyRange.lowerBound),
            max: Float(AKVocalTract.frequencyRange.upperBound),
            unit: .hertz,
            flags: .default)
        let tonguePosition = AUParameterTree.createParameter(
            identifier: "tonguePosition",
            name: "Tongue position (0-1)",
            address: AKVocalTractParameter.tonguePosition.rawValue,
            min: Float(AKVocalTract.tonguePositionRange.lowerBound),
            max: Float(AKVocalTract.tonguePositionRange.upperBound),
            unit: .generic,
            flags: .default)
        let tongueDiameter = AUParameterTree.createParameter(
            identifier: "tongueDiameter",
            name: "Tongue diameter (0-1)",
            address: AKVocalTractParameter.tongueDiameter.rawValue,
            min: Float(AKVocalTract.tongueDiameterRange.lowerBound),
            max: Float(AKVocalTract.tongueDiameterRange.upperBound),
            unit: .generic,
            flags: .default)
        let tenseness = AUParameterTree.createParameter(
            identifier: "tenseness",
            name: "Vocal tenseness. 0 = all breath. 1=fully saturated.",
            address: AKVocalTractParameter.tenseness.rawValue,
            min: Float(AKVocalTract.tensenessRange.lowerBound),
            max: Float(AKVocalTract.tensenessRange.upperBound),
            unit: .generic,
            flags: .default)
        let nasality = AUParameterTree.createParameter(
            identifier: "nasality",
            name: "Sets the velum size. Larger values of this creates more nasally sounds.",
            address: AKVocalTractParameter.nasality.rawValue,
            min: Float(AKVocalTract.nasalityRange.lowerBound),
            max: Float(AKVocalTract.nasalityRange.upperBound),
            unit: .generic,
            flags: .default)
        
        setParameterTree(AUParameterTree.createTree(withChildren: [frequency, tonguePosition, tongueDiameter, tenseness, nasality]))
        frequency.value = Float(AKVocalTract.defaultFrequency)
        tonguePosition.value = Float(AKVocalTract.defaultTonguePosition)
        tongueDiameter.value = Float(AKVocalTract.defaultTongueDiameter)
        tenseness.value = Float(AKVocalTract.defaultTenseness)
        nasality.value = Float(AKVocalTract.defaultNasality)
    }

    public override var canProcessInPlace: Bool { return true }

}
