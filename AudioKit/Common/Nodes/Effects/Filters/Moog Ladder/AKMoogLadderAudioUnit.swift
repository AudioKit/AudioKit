// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKMoogLadderAudioUnit: AKAudioUnitBase {

    let cutoffFrequency = AUParameter(
        identifier: "cutoffFrequency",
        name: "Cutoff Frequency (Hz)",
        address: AKMoogLadderParameter.cutoffFrequency.rawValue,
        range: AKMoogLadder.cutoffFrequencyRange,
        unit: .hertz,
        flags: .default)

    let resonance = AUParameter(
        identifier: "resonance",
        name: "Resonance (%)",
        address: AKMoogLadderParameter.resonance.rawValue,
        range: AKMoogLadder.resonanceRange,
        unit: .percent,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createMoogLadderDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [cutoffFrequency, resonance])
    }
}
