//
//  AKThreePoleLowpassFilterAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKThreePoleLowpassFilterAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKThreePoleLowpassFilterParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKThreePoleLowpassFilterParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var distortion: Double = AKThreePoleLowpassFilter.defaultDistortion {
        didSet { setParameter(.distortion, value: distortion) }
    }

    var cutoffFrequency: Double = AKThreePoleLowpassFilter.defaultCutoffFrequency {
        didSet { setParameter(.cutoffFrequency, value: cutoffFrequency) }
    }

    var resonance: Double = AKThreePoleLowpassFilter.defaultResonance {
        didSet { setParameter(.resonance, value: resonance) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createThreePoleLowpassFilterDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let distortion = AUParameterTree.createParameter(
            identifier: "distortion",
            name: "Distortion (%)",
            address: AKThreePoleLowpassFilterParameter.distortion.rawValue,
            min: Float(AKThreePoleLowpassFilter.distortionRange.lowerBound),
            max: Float(AKThreePoleLowpassFilter.distortionRange.upperBound),
            unit: .percent,
            flags: .default)
        let cutoffFrequency = AUParameterTree.createParameter(
            identifier: "cutoffFrequency",
            name: "Cutoff Frequency (Hz)",
            address: AKThreePoleLowpassFilterParameter.cutoffFrequency.rawValue,
            min: Float(AKThreePoleLowpassFilter.cutoffFrequencyRange.lowerBound),
            max: Float(AKThreePoleLowpassFilter.cutoffFrequencyRange.upperBound),
            unit: .hertz,
            flags: .default)
        let resonance = AUParameterTree.createParameter(
            identifier: "resonance",
            name: "Resonance (%)",
            address: AKThreePoleLowpassFilterParameter.resonance.rawValue,
            min: Float(AKThreePoleLowpassFilter.resonanceRange.lowerBound),
            max: Float(AKThreePoleLowpassFilter.resonanceRange.upperBound),
            unit: .percent,
            flags: .default)
        
        setParameterTree(AUParameterTree.createTree(withChildren: [distortion, cutoffFrequency, resonance]))
        distortion.value = Float(AKThreePoleLowpassFilter.defaultDistortion)
        cutoffFrequency.value = Float(AKThreePoleLowpassFilter.defaultCutoffFrequency)
        resonance.value = Float(AKThreePoleLowpassFilter.defaultResonance)
    }

    public override var canProcessInPlace: Bool { return true }

}
