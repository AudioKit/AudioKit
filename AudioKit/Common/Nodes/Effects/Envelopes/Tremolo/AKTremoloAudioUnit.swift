// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKTremoloAudioUnit: AKAudioUnitBase {

    let frequency = AUParameter(
        identifier: "frequency",
        name: "Frequency (Hz)",
        address: AKTremoloParameter.frequency.rawValue,
        range: AKTremolo.frequencyRange,
        unit: .hertz,
        flags: .default)

    let depth = AUParameter(
        identifier: "depth",
        name: "Depth",
        address: AKTremoloParameter.depth.rawValue,
        range: AKTremolo.depthRange,
        unit: .generic,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createTremoloDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [frequency, depth])
    }
}
