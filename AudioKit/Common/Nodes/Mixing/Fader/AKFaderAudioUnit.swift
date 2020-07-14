// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

public class AKFaderAudioUnit: AKAudioUnitBase {
    let leftGain = AUParameter(
        identifier: "leftGain",
        name: "Left Gain",
        address: AKFaderParameter.leftGain.rawValue,
        range: AKFader.gainRange,
        unit: .linearGain,
        flags: .default
    )

    let rightGain = AUParameter(
        identifier: "rightGain",
        name: "Right Gain",
        address: AKFaderParameter.rightGain.rawValue,
        range: AKFader.gainRange,
        unit: .linearGain,
        flags: .default
    )

    let flipStereo = AUParameter(
        identifier: "flipStereo",
        name: "Flip Stereo",
        address: AKFaderParameter.flipStereo.rawValue,
        range: 0.0 ... 1.0,
        unit: .boolean,
        flags: .default
    )

    let mixToMono = AUParameter(
        identifier: "mixToMono",
        name: "Mix To Mono",
        address: AKFaderParameter.mixToMono.rawValue,
        range: 0.0 ... 1.0,
        unit: .boolean,
        flags: .default
    )

    public override func createDSP() -> AKDSPRef {
        return createFaderDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [leftGain,
                                                                  rightGain,
                                                                  flipStereo,
                                                                  mixToMono])
    }
}
