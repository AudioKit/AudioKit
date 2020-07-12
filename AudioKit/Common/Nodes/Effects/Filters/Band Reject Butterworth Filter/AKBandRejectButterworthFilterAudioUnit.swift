// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKBandRejectButterworthFilterAudioUnit: AKAudioUnitBase {

    let centerFrequency = AUParameter(
        identifier: "centerFrequency",
        name: "Center Frequency (Hz)",
        address: AKBandRejectButterworthFilterParameter.centerFrequency.rawValue,
        range: 12.0 ... 20_000.0,
        unit: .hertz,
        flags: .default)

    let bandwidth = AUParameter(
        identifier: "bandwidth",
        name: "Bandwidth (Hz)",
        address: AKBandRejectButterworthFilterParameter.bandwidth.rawValue,
        range: 0.0 ... 20_000.0,
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
