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
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKKorgLowPassFilterParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
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
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createKorgLowPassFilterDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let cutoffFrequency = AUParameterTree.createParameter(
            withIdentifier: "cutoffFrequency",
            name: "Filter cutoff",
            address: AUParameterAddress(0),
            min: Float(AKKorgLowPassFilter.cutoffFrequencyRange.lowerBound),
            max: Float(AKKorgLowPassFilter.cutoffFrequencyRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let resonance = AUParameterTree.createParameter(
            withIdentifier: "resonance",
            name: "Filter resonance (should be between 0-2)",
            address: AUParameterAddress(1),
            min: Float(AKKorgLowPassFilter.resonanceRange.lowerBound),
            max: Float(AKKorgLowPassFilter.resonanceRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let saturation = AUParameterTree.createParameter(
            withIdentifier: "saturation",
            name: "Filter saturation.",
            address: AUParameterAddress(2),
            min: Float(AKKorgLowPassFilter.saturationRange.lowerBound),
            max: Float(AKKorgLowPassFilter.saturationRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [cutoffFrequency, resonance, saturation]))
        cutoffFrequency.value = Float(AKKorgLowPassFilter.defaultCutoffFrequency)
        resonance.value = Float(AKKorgLowPassFilter.defaultResonance)
        saturation.value = Float(AKKorgLowPassFilter.defaultSaturation)
    }

    public override var canProcessInPlace: Bool { return true } 

}
