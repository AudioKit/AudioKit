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

        let cutoffFrequency = AUParameter(
            identifier: "cutoffFrequency",
            name: "Filter cutoff",
            address: AKKorgLowPassFilterParameter.cutoffFrequency.rawValue,
            range: AKKorgLowPassFilter.cutoffFrequencyRange,
            unit: .hertz,
            flags: .default)
        let resonance = AUParameter(
            identifier: "resonance",
            name: "Filter resonance (should be between 0-2)",
            address: AKKorgLowPassFilterParameter.resonance.rawValue,
            range: AKKorgLowPassFilter.resonanceRange,
            unit: .generic,
            flags: .default)
        let saturation = AUParameter(
            identifier: "saturation",
            name: "Filter saturation.",
            address: AKKorgLowPassFilterParameter.saturation.rawValue,
            range: AKKorgLowPassFilter.saturationRange,
            unit: .generic,
            flags: .default)

        setParameterTree(AUParameterTree(children: [cutoffFrequency, resonance, saturation]))
        cutoffFrequency.value = Float(AKKorgLowPassFilter.defaultCutoffFrequency)
        resonance.value = Float(AKKorgLowPassFilter.defaultResonance)
        saturation.value = Float(AKKorgLowPassFilter.defaultSaturation)
    }

    public override var canProcessInPlace: Bool { return true }

}
