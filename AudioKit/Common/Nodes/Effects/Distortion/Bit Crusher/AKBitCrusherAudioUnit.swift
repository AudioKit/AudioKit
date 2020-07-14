// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

public class AKBitCrusherAudioUnit: AKAudioUnitBase {

    let bitDepth = AUParameter(
        identifier: "bitDepth",
        name: "Bit Depth",
        address: AKBitCrusherParameter.bitDepth.rawValue,
        range: 1 ... 24,
        unit: .generic,
        flags: .default)

    let sampleRate = AUParameter(
        identifier: "sampleRate",
        name: "Sample Rate (Hz)",
        address: AKBitCrusherParameter.sampleRate.rawValue,
        range: 0.0 ... 20_000.0,
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
