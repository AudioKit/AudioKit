// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKTremoloAudioUnit: AKAudioUnitBase {

    private(set) var frequency: AUParameter!

    private(set) var depth: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createTremoloDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        frequency = AUParameter(
            identifier: "frequency",
            name: "Frequency (Hz)",
            address: AKTremoloParameter.frequency.rawValue,
            range: AKTremolo.frequencyRange,
            unit: .hertz,
            flags: .default)
        depth = AUParameter(
            identifier: "depth",
            name: "Depth",
            address: AKTremoloParameter.depth.rawValue,
            range: AKTremolo.depthRange,
            unit: .generic,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [frequency, depth])

        frequency.value = AUValue(AKTremolo.defaultFrequency)
        depth.value = AUValue(AKTremolo.defaultDepth)
    }
}
