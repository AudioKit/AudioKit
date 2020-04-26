// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKRolandTB303FilterAudioUnit: AKAudioUnitBase {

    private(set) var cutoffFrequency: AUParameter!

    private(set) var resonance: AUParameter!

    private(set) var distortion: AUParameter!

    private(set) var resonanceAsymmetry: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createRolandTB303FilterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        cutoffFrequency = AUParameter(
            identifier: "cutoffFrequency",
            name: "Cutoff Frequency (Hz)",
            address: AKRolandTB303FilterParameter.cutoffFrequency.rawValue,
            range: AKRolandTB303Filter.cutoffFrequencyRange,
            unit: .hertz,
            flags: .default)
        resonance = AUParameter(
            identifier: "resonance",
            name: "Resonance",
            address: AKRolandTB303FilterParameter.resonance.rawValue,
            range: AKRolandTB303Filter.resonanceRange,
            unit: .generic,
            flags: .default)
        distortion = AUParameter(
            identifier: "distortion",
            name: "Distortion",
            address: AKRolandTB303FilterParameter.distortion.rawValue,
            range: AKRolandTB303Filter.distortionRange,
            unit: .generic,
            flags: .default)
        resonanceAsymmetry = AUParameter(
            identifier: "resonanceAsymmetry",
            name: "Resonance Asymmetry",
            address: AKRolandTB303FilterParameter.resonanceAsymmetry.rawValue,
            range: AKRolandTB303Filter.resonanceAsymmetryRange,
            unit: .generic,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [cutoffFrequency, resonance, distortion, resonanceAsymmetry])

        cutoffFrequency.value = AUValue(AKRolandTB303Filter.defaultCutoffFrequency)
        resonance.value = AUValue(AKRolandTB303Filter.defaultResonance)
        distortion.value = AUValue(AKRolandTB303Filter.defaultDistortion)
        resonanceAsymmetry.value = AUValue(AKRolandTB303Filter.defaultResonanceAsymmetry)
    }
}
