// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKRolandTB303FilterAudioUnit: AKAudioUnitBase {

    let cutoffFrequency = AUParameter(
        identifier: "cutoffFrequency",
        name: "Cutoff Frequency (Hz)",
        address: AKRolandTB303FilterParameter.cutoffFrequency.rawValue,
        range: 12.0 ... 20_000.0,
        unit: .hertz,
        flags: .default)

    let resonance = AUParameter(
        identifier: "resonance",
        name: "Resonance",
        address: AKRolandTB303FilterParameter.resonance.rawValue,
        range: 0.0 ... 2.0,
        unit: .generic,
        flags: .default)

    let distortion = AUParameter(
        identifier: "distortion",
        name: "Distortion",
        address: AKRolandTB303FilterParameter.distortion.rawValue,
        range: 0.0 ... 4.0,
        unit: .generic,
        flags: .default)

    let resonanceAsymmetry = AUParameter(
        identifier: "resonanceAsymmetry",
        name: "Resonance Asymmetry",
        address: AKRolandTB303FilterParameter.resonanceAsymmetry.rawValue,
        range: 0.0 ... 1.0,
        unit: .generic,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createRolandTB303FilterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [cutoffFrequency,
                                                                  resonance,
                                                                  distortion,
                                                                  resonanceAsymmetry])
    }
}
