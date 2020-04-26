// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKThreePoleLowpassFilterAudioUnit: AKAudioUnitBase {

    private(set) var distortion: AUParameter!

    private(set) var cutoffFrequency: AUParameter!

    private(set) var resonance: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createThreePoleLowpassFilterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        distortion = AUParameter(
            identifier: "distortion",
            name: "Distortion (%)",
            address: AKThreePoleLowpassFilterParameter.distortion.rawValue,
            range: AKThreePoleLowpassFilter.distortionRange,
            unit: .percent,
            flags: .default)
        cutoffFrequency = AUParameter(
            identifier: "cutoffFrequency",
            name: "Cutoff Frequency (Hz)",
            address: AKThreePoleLowpassFilterParameter.cutoffFrequency.rawValue,
            range: AKThreePoleLowpassFilter.cutoffFrequencyRange,
            unit: .hertz,
            flags: .default)
        resonance = AUParameter(
            identifier: "resonance",
            name: "Resonance (%)",
            address: AKThreePoleLowpassFilterParameter.resonance.rawValue,
            range: AKThreePoleLowpassFilter.resonanceRange,
            unit: .percent,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [distortion, cutoffFrequency, resonance])

        distortion.value = AUValue(AKThreePoleLowpassFilter.defaultDistortion)
        cutoffFrequency.value = AUValue(AKThreePoleLowpassFilter.defaultCutoffFrequency)
        resonance.value = AUValue(AKThreePoleLowpassFilter.defaultResonance)
    }
}
