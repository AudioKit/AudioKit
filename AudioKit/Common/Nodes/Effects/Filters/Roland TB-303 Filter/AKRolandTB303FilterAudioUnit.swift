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
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKRolandTB303FilterParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
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
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createRolandTB303FilterDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let cutoffFrequency = AUParameterTree.createParameter(
            withIdentifier: "cutoffFrequency",
            name: "Cutoff Frequency (Hz)",
            address: AUParameterAddress(0),
            min: Float(AKRolandTB303Filter.cutoffFrequencyRange.lowerBound),
            max: Float(AKRolandTB303Filter.cutoffFrequencyRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let resonance = AUParameterTree.createParameter(
            withIdentifier: "resonance",
            name: "Resonance",
            address: AUParameterAddress(1),
            min: Float(AKRolandTB303Filter.resonanceRange.lowerBound),
            max: Float(AKRolandTB303Filter.resonanceRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let distortion = AUParameterTree.createParameter(
            withIdentifier: "distortion",
            name: "Distortion",
            address: AUParameterAddress(2),
            min: Float(AKRolandTB303Filter.distortionRange.lowerBound),
            max: Float(AKRolandTB303Filter.distortionRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let resonanceAsymmetry = AUParameterTree.createParameter(
            withIdentifier: "resonanceAsymmetry",
            name: "Resonance Asymmetry",
            address: AUParameterAddress(3),
            min: Float(AKRolandTB303Filter.resonanceAsymmetryRange.lowerBound),
            max: Float(AKRolandTB303Filter.resonanceAsymmetryRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [cutoffFrequency, resonance, distortion, resonanceAsymmetry]))
        cutoffFrequency.value = Float(AKRolandTB303Filter.defaultCutoffFrequency)
        resonance.value = Float(AKRolandTB303Filter.defaultResonance)
        distortion.value = Float(AKRolandTB303Filter.defaultDistortion)
        resonanceAsymmetry.value = Float(AKRolandTB303Filter.defaultResonanceAsymmetry)
    }

    public override var canProcessInPlace: Bool { return true } 

}
