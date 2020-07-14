// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

public class AKHighShelfParametricEqualizerFilterAudioUnit: AKAudioUnitBase {

    let centerFrequency = AUParameter(
        identifier: "centerFrequency",
        name: "Corner Frequency (Hz)",
        address: AKHighShelfParametricEqualizerFilterParameter.centerFrequency.rawValue,
        range: 12.0 ... 20_000.0,
        unit: .hertz,
        flags: .default)

    let gain = AUParameter(
        identifier: "gain",
        name: "Gain",
        address: AKHighShelfParametricEqualizerFilterParameter.gain.rawValue,
        range: 0.0 ... 10.0,
        unit: .generic,
        flags: .default)

    let q = AUParameter(
        identifier: "q",
        name: "Q",
        address: AKHighShelfParametricEqualizerFilterParameter.Q.rawValue,
        range: 0.0 ... 2.0,
        unit: .generic,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createHighShelfParametricEqualizerFilterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [centerFrequency, gain, q])
    }
}
