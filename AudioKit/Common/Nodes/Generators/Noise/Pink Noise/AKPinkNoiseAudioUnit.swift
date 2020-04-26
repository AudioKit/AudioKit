// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKPinkNoiseAudioUnit: AKAudioUnitBase {

    private(set) var amplitude: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createPinkNoiseDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        amplitude = AUParameter(
            identifier: "amplitude",
            name: "Amplitude",
            address: AKPinkNoiseParameter.amplitude.rawValue,
            range: AKPinkNoise.amplitudeRange,
            unit: .generic,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [amplitude])

        amplitude.value = AUValue(AKPinkNoise.defaultAmplitude)
    }
}
