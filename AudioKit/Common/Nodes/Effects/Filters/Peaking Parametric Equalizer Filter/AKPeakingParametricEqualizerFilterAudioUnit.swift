// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKPeakingParametricEqualizerFilterAudioUnit: AKAudioUnitBase {

    private(set) var centerFrequency: AUParameter!

    private(set) var gain: AUParameter!

    private(set) var q: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createPeakingParametricEqualizerFilterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        centerFrequency = AUParameter(
            identifier: "centerFrequency",
            name: "Center Frequency (Hz)",
            address: AKPeakingParametricEqualizerFilterParameter.centerFrequency.rawValue,
            range: AKPeakingParametricEqualizerFilter.centerFrequencyRange,
            unit: .hertz,
            flags: .default)
        gain = AUParameter(
            identifier: "gain",
            name: "Gain",
            address: AKPeakingParametricEqualizerFilterParameter.gain.rawValue,
            range: AKPeakingParametricEqualizerFilter.gainRange,
            unit: .generic,
            flags: .default)
        q = AUParameter(
            identifier: "q",
            name: "Q",
            address: AKPeakingParametricEqualizerFilterParameter.Q.rawValue,
            range: AKPeakingParametricEqualizerFilter.qRange,
            unit: .generic,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [centerFrequency, gain, q])

        centerFrequency.value = AUValue(AKPeakingParametricEqualizerFilter.defaultCenterFrequency)
        gain.value = AUValue(AKPeakingParametricEqualizerFilter.defaultGain)
        q.value = AUValue(AKPeakingParametricEqualizerFilter.defaultQ)
    }
}
