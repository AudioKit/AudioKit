// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKPeakingParametricEqualizerFilterAudioUnit: AKAudioUnitBase {

    let centerFrequency = AUParameter(
        identifier: "centerFrequency",
        name: "Center Frequency (Hz)",
        address: AKPeakingParametricEqualizerFilterParameter.centerFrequency.rawValue,
        range: AKPeakingParametricEqualizerFilter.centerFrequencyRange,
        unit: .hertz,
        flags: .default)

    let gain = AUParameter(
        identifier: "gain",
        name: "Gain",
        address: AKPeakingParametricEqualizerFilterParameter.gain.rawValue,
        range: AKPeakingParametricEqualizerFilter.gainRange,
        unit: .generic,
        flags: .default)

    let q = AUParameter(
        identifier: "q",
        name: "Q",
        address: AKPeakingParametricEqualizerFilterParameter.Q.rawValue,
        range: AKPeakingParametricEqualizerFilter.qRange,
        unit: .generic,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createPeakingParametricEqualizerFilterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [centerFrequency, gain, q])
    }
}
