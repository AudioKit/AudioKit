// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKKorgLowPassFilterAudioUnit: AKAudioUnitBase {

    private(set) var cutoffFrequency: AUParameter!

    private(set) var resonance: AUParameter!

    private(set) var saturation: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createKorgLowPassFilterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        cutoffFrequency = AUParameter(
            identifier: "cutoffFrequency",
            name: "Filter cutoff",
            address: AKKorgLowPassFilterParameter.cutoffFrequency.rawValue,
            range: AKKorgLowPassFilter.cutoffFrequencyRange,
            unit: .hertz,
            flags: .default)
        resonance = AUParameter(
            identifier: "resonance",
            name: "Filter resonance (should be between 0-2)",
            address: AKKorgLowPassFilterParameter.resonance.rawValue,
            range: AKKorgLowPassFilter.resonanceRange,
            unit: .generic,
            flags: .default)
        saturation = AUParameter(
            identifier: "saturation",
            name: "Filter saturation.",
            address: AKKorgLowPassFilterParameter.saturation.rawValue,
            range: AKKorgLowPassFilter.saturationRange,
            unit: .generic,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [cutoffFrequency, resonance, saturation])

        cutoffFrequency.value = AUValue(AKKorgLowPassFilter.defaultCutoffFrequency)
        resonance.value = AUValue(AKKorgLowPassFilter.defaultResonance)
        saturation.value = AUValue(AKKorgLowPassFilter.defaultSaturation)
    }
}
