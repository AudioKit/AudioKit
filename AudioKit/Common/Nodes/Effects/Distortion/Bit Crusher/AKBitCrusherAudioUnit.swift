// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKBitCrusherAudioUnit: AKAudioUnitBase {

    let bitDepth = AUParameter(
        identifier: "bitDepth",
        name: "Bit Depth",
        address: AKBitCrusherParameter.bitDepth.rawValue,
        range: AKBitCrusher.bitDepthRange,
        unit: .generic,
        flags: .default)

    let sampleRate = AUParameter(
        identifier: "sampleRate",
        name: "Sample Rate (Hz)",
        address: AKBitCrusherParameter.sampleRate.rawValue,
        range: AKBitCrusher.sampleRateRange,
        unit: .hertz,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createBitCrusherDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [bitDepth, sampleRate])
    }
}
