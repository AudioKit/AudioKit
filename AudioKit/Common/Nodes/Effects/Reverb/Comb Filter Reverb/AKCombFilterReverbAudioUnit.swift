// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

public class AKCombFilterReverbAudioUnit: AKAudioUnitBase {

    let reverbDuration = AUParameter(
        identifier: "reverbDuration",
        name: "Reverb Duration (Seconds)",
        address: AKCombFilterReverbParameter.reverbDuration.rawValue,
        range: 0.0 ... 10.0,
        unit: .seconds,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createCombFilterReverbDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [reverbDuration])
    }
}
