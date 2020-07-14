// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

public class AKThreePoleLowpassFilterAudioUnit: AKAudioUnitBase {

    let distortion = AUParameter(
        identifier: "distortion",
        name: "Distortion (%)",
        address: AKThreePoleLowpassFilterParameter.distortion.rawValue,
        range: 0.0 ... 2.0,
        unit: .percent,
        flags: .default)

    let cutoffFrequency = AUParameter(
        identifier: "cutoffFrequency",
        name: "Cutoff Frequency (Hz)",
        address: AKThreePoleLowpassFilterParameter.cutoffFrequency.rawValue,
        range: 12.0 ... 20_000.0,
        unit: .hertz,
        flags: .default)

    let resonance = AUParameter(
        identifier: "resonance",
        name: "Resonance (%)",
        address: AKThreePoleLowpassFilterParameter.resonance.rawValue,
        range: 0.0 ... 2.0,
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
