// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKBandPassButterworthFilterAudioUnit: AKAudioUnitBase {

    private(set) var centerFrequency: AUParameter!

    private(set) var bandwidth: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createBandPassButterworthFilterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        centerFrequency = AUParameter(
            identifier: "centerFrequency",
            name: "Center Frequency (Hz)",
            address: AKBandPassButterworthFilterParameter.centerFrequency.rawValue,
            range: AKBandPassButterworthFilter.centerFrequencyRange,
            unit: .hertz,
            flags: .default)
        bandwidth = AUParameter(
            identifier: "bandwidth",
            name: "Bandwidth (Hz)",
            address: AKBandPassButterworthFilterParameter.bandwidth.rawValue,
            range: AKBandPassButterworthFilter.bandwidthRange,
            unit: .hertz,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [centerFrequency, bandwidth])

        centerFrequency.value = AUValue(AKBandPassButterworthFilter.defaultCenterFrequency)
        bandwidth.value = AUValue(AKBandPassButterworthFilter.defaultBandwidth)
    }
}
