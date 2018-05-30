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
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKThreePoleLowpassFilterParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
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
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createThreePoleLowpassFilterDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let distortion = AUParameterTree.createParameter(
            withIdentifier: "distortion",
            name: "Distortion (%)",
            address: AUParameterAddress(0),
            min: Float(AKThreePoleLowpassFilter.distortionRange.lowerBound),
            max: Float(AKThreePoleLowpassFilter.distortionRange.upperBound),
            unit: .percent,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let cutoffFrequency = AUParameterTree.createParameter(
            withIdentifier: "cutoffFrequency",
            name: "Cutoff Frequency (Hz)",
            address: AUParameterAddress(1),
            min: Float(AKThreePoleLowpassFilter.cutoffFrequencyRange.lowerBound),
            max: Float(AKThreePoleLowpassFilter.cutoffFrequencyRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let resonance = AUParameterTree.createParameter(
            withIdentifier: "resonance",
            name: "Resonance (%)",
            address: AUParameterAddress(2),
            min: Float(AKThreePoleLowpassFilter.resonanceRange.lowerBound),
            max: Float(AKThreePoleLowpassFilter.resonanceRange.upperBound),
            unit: .percent,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [distortion, cutoffFrequency, resonance]))
        distortion.value = Float(AKThreePoleLowpassFilter.defaultDistortion)
        cutoffFrequency.value = Float(AKThreePoleLowpassFilter.defaultCutoffFrequency)
        resonance.value = Float(AKThreePoleLowpassFilter.defaultResonance)
    }

    public override var canProcessInPlace: Bool { return true } 

}
