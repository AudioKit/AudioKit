// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

public class AKEqualizerFilterAudioUnit: AKAudioUnitBase {

    let centerFrequency = AUParameter(
        identifier: "centerFrequency",
        name: "Center Frequency (Hz)",
        address: AKEqualizerFilterParameter.centerFrequency.rawValue,
        range: 12.0 ... 20_000.0,
        unit: .hertz,
        flags: .default)

    let bandwidth = AUParameter(
        identifier: "bandwidth",
        name: "Bandwidth (Hz)",
        address: AKEqualizerFilterParameter.bandwidth.rawValue,
        range: 0.0 ... 20_000.0,
        unit: .hertz,
        flags: .default)

    let gain = AUParameter(
        identifier: "gain",
        name: "Gain (%)",
        address: AKEqualizerFilterParameter.gain.rawValue,
        range: -100.0 ... 100.0,
        unit: .percent,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createEqualizerFilterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [centerFrequency, bandwidth, gain])
    }
}
