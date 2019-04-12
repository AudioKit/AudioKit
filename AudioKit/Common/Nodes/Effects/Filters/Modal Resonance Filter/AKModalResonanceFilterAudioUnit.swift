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

        let frequency = AUParameter(
            identifier: "frequency",
            name: "Resonant Frequency (Hz)",
            address: AKModalResonanceFilterParameter.frequency.rawValue,
            range: AKModalResonanceFilter.frequencyRange,
            unit: .hertz,
            flags: .default)
        let qualityFactor = AUParameter(
            identifier: "qualityFactor",
            name: "Quality Factor",
            address: AKModalResonanceFilterParameter.qualityFactor.rawValue,
            range: AKModalResonanceFilter.qualityFactorRange,
            unit: .generic,
            flags: .default)

        setParameterTree(AUParameterTree(children: [frequency, qualityFactor]))
        frequency.value = Float(AKModalResonanceFilter.defaultFrequency)
        qualityFactor.value = Float(AKModalResonanceFilter.defaultQualityFactor)
    }

    public override var canProcessInPlace: Bool { return true }

}
