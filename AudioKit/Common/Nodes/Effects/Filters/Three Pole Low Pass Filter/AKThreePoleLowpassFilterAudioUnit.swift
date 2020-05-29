// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKThreePoleLowpassFilterAudioUnit: AKAudioUnitBase {

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

    public override func createDSP() -> AKDSPRef {
        return createThreePoleLowpassFilterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [distortion, cutoffFrequency, resonance])
    }
}
