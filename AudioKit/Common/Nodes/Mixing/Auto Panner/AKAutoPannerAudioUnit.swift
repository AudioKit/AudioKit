// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKAutoPannerAudioUnit: AKAudioUnitBase {

    var frequency: AUParameter!

    var depth: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createAutoPannerDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        frequency = AUParameter(
            identifier: "frequency",
            name: "Frequency (Hz)",
            address: 0,
            range: 0.0...100.0,
            unit: .hertz,
            flags: .default)
        depth = AUParameter(
            identifier: "depth",
            name: "Depth",
            address: 1,
            range: 0.0...1.0,
            unit: .generic,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [frequency, depth])

        frequency.value = 10.0
        depth.value = 1.0
    }
}
