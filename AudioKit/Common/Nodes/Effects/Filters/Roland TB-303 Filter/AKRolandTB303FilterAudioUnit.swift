//
//  AKRolandTB303FilterAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKRolandTB303FilterAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKRolandTB303FilterParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKRolandTB303FilterParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var cutoffFrequency: Double = AKRolandTB303Filter.defaultCutoffFrequency {
        didSet { setParameter(.cutoffFrequency, value: cutoffFrequency) }
    }

    var resonance: Double = AKRolandTB303Filter.defaultResonance {
        didSet { setParameter(.resonance, value: resonance) }
    }

    var distortion: Double = AKRolandTB303Filter.defaultDistortion {
        didSet { setParameter(.distortion, value: distortion) }
    }

    var resonanceAsymmetry: Double = AKRolandTB303Filter.defaultResonanceAsymmetry {
        didSet { setParameter(.resonanceAsymmetry, value: resonanceAsymmetry) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createRolandTB303FilterDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let cutoffFrequency = AUParameterTree.createParameter(
            withIdentifier: "cutoffFrequency",
            name: "Cutoff Frequency (Hz)",
            address: AKRolandTB303FilterParameter.cutoffFrequency.rawValue,
            min: Float(AKRolandTB303Filter.cutoffFrequencyRange.lowerBound),
            max: Float(AKRolandTB303Filter.cutoffFrequencyRange.upperBound),
            unit: .hertz,
            flags: .default)
        let resonance = AUParameterTree.createParameter(
            withIdentifier: "resonance",
            name: "Resonance",
            address: AKRolandTB303FilterParameter.resonance.rawValue,
            min: Float(AKRolandTB303Filter.resonanceRange.lowerBound),
            max: Float(AKRolandTB303Filter.resonanceRange.upperBound),
            unit: .generic,
            flags: .default)
        let distortion = AUParameterTree.createParameter(
            withIdentifier: "distortion",
            name: "Distortion",
            address: AKRolandTB303FilterParameter.distortion.rawValue,
            min: Float(AKRolandTB303Filter.distortionRange.lowerBound),
            max: Float(AKRolandTB303Filter.distortionRange.upperBound),
            unit: .generic,
            flags: .default)
        let resonanceAsymmetry = AUParameterTree.createParameter(
            withIdentifier: "resonanceAsymmetry",
            name: "Resonance Asymmetry",
            address: AKRolandTB303FilterParameter.resonanceAsymmetry.rawValue,
            min: Float(AKRolandTB303Filter.resonanceAsymmetryRange.lowerBound),
            max: Float(AKRolandTB303Filter.resonanceAsymmetryRange.upperBound),
            unit: .generic,
            flags: .default)
        
        setParameterTree(AUParameterTree.createTree(withChildren: [cutoffFrequency, resonance, distortion, resonanceAsymmetry]))
        cutoffFrequency.value = Float(AKRolandTB303Filter.defaultCutoffFrequency)
        resonance.value = Float(AKRolandTB303Filter.defaultResonance)
        distortion.value = Float(AKRolandTB303Filter.defaultDistortion)
        resonanceAsymmetry.value = Float(AKRolandTB303Filter.defaultResonanceAsymmetry)
    }

    public override var canProcessInPlace: Bool { return true }

}
