// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKBandRejectButterworthFilterAudioUnit: AKAudioUnitBase {

    let centerFrequency = AUParameter(
        identifier: "centerFrequency",
        name: "Center Frequency (Hz)",
        address: AKBandRejectButterworthFilterParameter.centerFrequency.rawValue,
        range: AKBandRejectButterworthFilter.centerFrequencyRange,
        unit: .hertz,
        flags: .default)

    let bandwidth = AUParameter(
        identifier: "bandwidth",
        name: "Bandwidth (Hz)",
        address: AKBandRejectButterworthFilterParameter.bandwidth.rawValue,
        range: AKBandRejectButterworthFilter.bandwidthRange,
        unit: .hertz,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createBandRejectButterworthFilterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [centerFrequency, bandwidth])
    }
}
