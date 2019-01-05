//
//  AKKorgLowPassFilterAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKKorgLowPassFilterAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKKorgLowPassFilterParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKKorgLowPassFilterParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var cutoffFrequency: Double = AKKorgLowPassFilter.defaultCutoffFrequency {
        didSet { setParameter(.cutoffFrequency, value: cutoffFrequency) }
    }

    var resonance: Double = AKKorgLowPassFilter.defaultResonance {
        didSet { setParameter(.resonance, value: resonance) }
    }

    var saturation: Double = AKKorgLowPassFilter.defaultSaturation {
        didSet { setParameter(.saturation, value: saturation) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createKorgLowPassFilterDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let cutoffFrequency = AUParameterTree.createParameter(
            withIdentifier: "cutoffFrequency",
            name: "Filter cutoff",
            address: AKKorgLowPassFilterParameter.cutoffFrequency.rawValue,
            min: Float(AKKorgLowPassFilter.cutoffFrequencyRange.lowerBound),
            max: Float(AKKorgLowPassFilter.cutoffFrequencyRange.upperBound),
            unit: .hertz,
            flags: .default)
        let resonance = AUParameterTree.createParameter(
            withIdentifier: "resonance",
            name: "Filter resonance (should be between 0-2)",
            address: AKKorgLowPassFilterParameter.resonance.rawValue,
            min: Float(AKKorgLowPassFilter.resonanceRange.lowerBound),
            max: Float(AKKorgLowPassFilter.resonanceRange.upperBound),
            unit: .generic,
            flags: .default)
        let saturation = AUParameterTree.createParameter(
            withIdentifier: "saturation",
            name: "Filter saturation.",
            address: AKKorgLowPassFilterParameter.saturation.rawValue,
            min: Float(AKKorgLowPassFilter.saturationRange.lowerBound),
            max: Float(AKKorgLowPassFilter.saturationRange.upperBound),
            unit: .generic,
            flags: .default)
        
        setParameterTree(AUParameterTree.createTree(withChildren: [cutoffFrequency, resonance, saturation]))
        cutoffFrequency.value = Float(AKKorgLowPassFilter.defaultCutoffFrequency)
        resonance.value = Float(AKKorgLowPassFilter.defaultResonance)
        saturation.value = Float(AKKorgLowPassFilter.defaultSaturation)
    }

    public override var canProcessInPlace: Bool { return true }

}
