// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKClipperAudioUnit: AKAudioUnitBase {

    let limit = AUParameter(
        identifier: "limit",
        name: "Threshold",
        address: AKClipperParameter.limit.rawValue,
        range: 0.0 ... 1.0,
        unit: .generic,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createClipperDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [limit])
    }
}
