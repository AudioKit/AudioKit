// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKCostelloReverbAudioUnit: AKAudioUnitBase {

    let feedback = AUParameter(
        identifier: "feedback",
        name: "Feedback",
        address: AKCostelloReverbParameter.feedback.rawValue,
        range: 0.0 ... 1.0,
        unit: .generic,
        flags: .default)

    let cutoffFrequency = AUParameter(
        identifier: "cutoffFrequency",
        name: "Cutoff Frequency",
        address: AKCostelloReverbParameter.cutoffFrequency.rawValue,
        range: 12.0 ... 20_000.0,
        unit: .hertz,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createCostelloReverbDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [feedback, cutoffFrequency])
    }
}
