// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKFlatFrequencyResponseReverbAudioUnit: AKAudioUnitBase {

    let reverbDuration = AUParameter(
        identifier: "reverbDuration",
        name: "Reverb Duration (Seconds)",
        address: AKFlatFrequencyResponseReverbParameter.reverbDuration.rawValue,
        range: 0 ... 10,
        unit: .seconds,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createFlatFrequencyResponseReverbDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [reverbDuration])
    }
}
