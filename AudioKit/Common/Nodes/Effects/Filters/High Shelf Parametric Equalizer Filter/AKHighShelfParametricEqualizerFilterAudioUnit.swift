// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKHighShelfParametricEqualizerFilterAudioUnit: AKAudioUnitBase {

    private(set) var centerFrequency: AUParameter!

    private(set) var gain: AUParameter!

    private(set) var q: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createHighShelfParametricEqualizerFilterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        centerFrequency = AUParameter(
            identifier: "centerFrequency",
            name: "Corner Frequency (Hz)",
            address: AKHighShelfParametricEqualizerFilterParameter.centerFrequency.rawValue,
            range: AKHighShelfParametricEqualizerFilter.centerFrequencyRange,
            unit: .hertz,
            flags: .default)
        gain = AUParameter(
            identifier: "gain",
            name: "Gain",
            address: AKHighShelfParametricEqualizerFilterParameter.gain.rawValue,
            range: AKHighShelfParametricEqualizerFilter.gainRange,
            unit: .generic,
            flags: .default)
        q = AUParameter(
            identifier: "q",
            name: "Q",
            address: AKHighShelfParametricEqualizerFilterParameter.Q.rawValue,
            range: AKHighShelfParametricEqualizerFilter.qRange,
            unit: .generic,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [centerFrequency, gain, q])

        centerFrequency.value = AUValue(AKHighShelfParametricEqualizerFilter.defaultCenterFrequency)
        gain.value = AUValue(AKHighShelfParametricEqualizerFilter.defaultGain)
        q.value = AUValue(AKHighShelfParametricEqualizerFilter.defaultQ)
    }
}
