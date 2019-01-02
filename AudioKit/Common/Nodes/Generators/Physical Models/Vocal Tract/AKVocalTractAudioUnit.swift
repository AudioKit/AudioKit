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

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let frequency = AUParameterTree.createParameter(
            withIdentifier: "frequency",
            name: "Glottal frequency.",
            address: AKVocalTractParameter.frequency.rawValue,
            min: Float(AKVocalTract.frequencyRange.lowerBound),
            max: Float(AKVocalTract.frequencyRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let tonguePosition = AUParameterTree.createParameter(
            withIdentifier: "tonguePosition",
            name: "Tongue position (0-1)",
            address: AKVocalTractParameter.tonguePosition.rawValue,
            min: Float(AKVocalTract.tonguePositionRange.lowerBound),
            max: Float(AKVocalTract.tonguePositionRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let tongueDiameter = AUParameterTree.createParameter(
            withIdentifier: "tongueDiameter",
            name: "Tongue diameter (0-1)",
            address: AKVocalTractParameter.tongueDiameter.rawValue,
            min: Float(AKVocalTract.tongueDiameterRange.lowerBound),
            max: Float(AKVocalTract.tongueDiameterRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let tenseness = AUParameterTree.createParameter(
            withIdentifier: "tenseness",
            name: "Vocal tenseness. 0 = all breath. 1=fully saturated.",
            address: AKVocalTractParameter.tenseness.rawValue,
            min: Float(AKVocalTract.tensenessRange.lowerBound),
            max: Float(AKVocalTract.tensenessRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let nasality = AUParameterTree.createParameter(
            withIdentifier: "nasality",
            name: "Sets the velum size. Larger values of this creates more nasally sounds.",
            address: AKVocalTractParameter.nasality.rawValue,
            min: Float(AKVocalTract.nasalityRange.lowerBound),
            max: Float(AKVocalTract.nasalityRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        
        setParameterTree(AUParameterTree.createTree(withChildren: [frequency, tonguePosition, tongueDiameter, tenseness, nasality]))
        frequency.value = Float(AKVocalTract.defaultFrequency)
        tonguePosition.value = Float(AKVocalTract.defaultTonguePosition)
        tongueDiameter.value = Float(AKVocalTract.defaultTongueDiameter)
        tenseness.value = Float(AKVocalTract.defaultTenseness)
        nasality.value = Float(AKVocalTract.defaultNasality)
    }

    public override var canProcessInPlace: Bool { return true }

}
