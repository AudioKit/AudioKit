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

        let distortion = AUParameter(
            identifier: "distortion",
            name: "Distortion (%)",
            address: AKThreePoleLowpassFilterParameter.distortion.rawValue,
            range: AKThreePoleLowpassFilter.distortionRange,
            unit: .percent,
            flags: .default)
        let cutoffFrequency = AUParameter(
            identifier: "cutoffFrequency",
            name: "Cutoff Frequency (Hz)",
            address: AKThreePoleLowpassFilterParameter.cutoffFrequency.rawValue,
            range: AKThreePoleLowpassFilter.cutoffFrequencyRange,
            unit: .hertz,
            flags: .default)
        let resonance = AUParameter(
            identifier: "resonance",
            name: "Resonance (%)",
            address: AKThreePoleLowpassFilterParameter.resonance.rawValue,
            range: AKThreePoleLowpassFilter.resonanceRange,
            unit: .percent,
            flags: .default)

        setParameterTree(AUParameterTree(children: [distortion, cutoffFrequency, resonance]))
        distortion.value = Float(AKThreePoleLowpassFilter.defaultDistortion)
        cutoffFrequency.value = Float(AKThreePoleLowpassFilter.defaultCutoffFrequency)
        resonance.value = Float(AKThreePoleLowpassFilter.defaultResonance)
    }

    public override var canProcessInPlace: Bool { return true }

}
