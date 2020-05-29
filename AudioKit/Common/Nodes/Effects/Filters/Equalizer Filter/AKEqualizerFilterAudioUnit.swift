// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKEqualizerFilterAudioUnit: AKAudioUnitBase {

    let centerFrequency = AUParameter(
        identifier: "centerFrequency",
        name: "Center Frequency (Hz)",
        address: AKEqualizerFilterParameter.centerFrequency.rawValue,
        range: AKEqualizerFilter.centerFrequencyRange,
        unit: .hertz,
        flags: .default)

    let bandwidth = AUParameter(
        identifier: "bandwidth",
        name: "Bandwidth (Hz)",
        address: AKEqualizerFilterParameter.bandwidth.rawValue,
        range: AKEqualizerFilter.bandwidthRange,
        unit: .hertz,
        flags: .default)

    let gain = AUParameter(
        identifier: "gain",
        name: "Gain (%)",
        address: AKEqualizerFilterParameter.gain.rawValue,
        range: AKEqualizerFilter.gainRange,
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
