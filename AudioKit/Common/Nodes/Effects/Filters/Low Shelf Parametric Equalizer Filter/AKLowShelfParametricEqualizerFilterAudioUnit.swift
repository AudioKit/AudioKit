// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKLowShelfParametricEqualizerFilterAudioUnit: AKAudioUnitBase {

    let cornerFrequency = AUParameter(
        identifier: "cornerFrequency",
        name: "Corner Frequency (Hz)",
        address: AKLowShelfParametricEqualizerFilterParameter.cornerFrequency.rawValue,
        range: AKLowShelfParametricEqualizerFilter.cornerFrequencyRange,
        unit: .hertz,
        flags: .default)

    let gain = AUParameter(
        identifier: "gain",
        name: "Gain",
        address: AKLowShelfParametricEqualizerFilterParameter.gain.rawValue,
        range: AKLowShelfParametricEqualizerFilter.gainRange,
        unit: .generic,
        flags: .default)

    let q = AUParameter(
        identifier: "q",
        name: "Q",
        address: AKLowShelfParametricEqualizerFilterParameter.Q.rawValue,
        range: AKLowShelfParametricEqualizerFilter.qRange,
        unit: .generic,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createLowShelfParametricEqualizerFilterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [cornerFrequency, gain, q])
    }
}
