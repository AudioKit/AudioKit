//
//  AKModalResonanceFilterAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKModalResonanceFilterAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKModalResonanceFilterParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKModalResonanceFilterParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var frequency: Double = AKModalResonanceFilter.defaultFrequency {
        didSet { setParameter(.frequency, value: frequency) }
    }

    var qualityFactor: Double = AKModalResonanceFilter.defaultQualityFactor {
        didSet { setParameter(.qualityFactor, value: qualityFactor) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createModalResonanceFilterDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let frequency = AUParameterTree.createParameter(
            withIdentifier: "frequency",
            name: "Resonant Frequency (Hz)",
            address: AKModalResonanceFilterParameter.frequency.rawValue,
            min: Float(AKModalResonanceFilter.frequencyRange.lowerBound),
            max: Float(AKModalResonanceFilter.frequencyRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: .default,
            valueStrings: nil,
            dependentParameters: nil
        )
        let qualityFactor = AUParameterTree.createParameter(
            withIdentifier: "qualityFactor",
            name: "Quality Factor",
            address: AKModalResonanceFilterParameter.qualityFactor.rawValue,
            min: Float(AKModalResonanceFilter.qualityFactorRange.lowerBound),
            max: Float(AKModalResonanceFilter.qualityFactorRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: .default,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [frequency, qualityFactor]))
        frequency.value = Float(AKModalResonanceFilter.defaultFrequency)
        qualityFactor.value = Float(AKModalResonanceFilter.defaultQualityFactor)
    }

    public override var canProcessInPlace: Bool { return true }

}
