// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKStereoFieldLimiterAudioUnit: AKAudioUnitBase {

    var amount: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createStereoFieldLimiterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        amount = AUParameter(
            identifier: "amount",
            name: "Limiting amount",
            address: 0,
            range: 0.0...1.0,
            unit: .generic,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [amount])

        amount.value = 1.0
    }
}
