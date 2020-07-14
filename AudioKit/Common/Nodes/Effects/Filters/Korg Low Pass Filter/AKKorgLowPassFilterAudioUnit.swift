// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

public class AKKorgLowPassFilterAudioUnit: AKAudioUnitBase {

    let cutoffFrequency = AUParameter(
        identifier: "cutoffFrequency",
        name: "Filter cutoff",
        address: AKKorgLowPassFilterParameter.cutoffFrequency.rawValue,
        range: 0.0 ... 22_050.0,
        unit: .hertz,
        flags: .default)

    let resonance = AUParameter(
        identifier: "resonance",
        name: "Filter resonance (should be between 0-2)",
        address: AKKorgLowPassFilterParameter.resonance.rawValue,
        range: 0.0 ... 2.0,
        unit: .generic,
        flags: .default)

    let saturation = AUParameter(
        identifier: "saturation",
        name: "Filter saturation.",
        address: AKKorgLowPassFilterParameter.saturation.rawValue,
        range: 0.0 ... 10.0,
        unit: .generic,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createKorgLowPassFilterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [cutoffFrequency, resonance, saturation])
    }
}
