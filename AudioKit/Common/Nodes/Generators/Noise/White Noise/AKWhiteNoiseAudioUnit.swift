// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKWhiteNoiseAudioUnit: AKAudioUnitBase {

    let amplitude = AUParameter(
        identifier: "amplitude",
        name: "Amplitude",
        address: AKWhiteNoiseParameter.amplitude.rawValue,
        range: AKWhiteNoise.amplitudeRange,
        unit: .generic,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createWhiteNoiseDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [amplitude])
    }
}
