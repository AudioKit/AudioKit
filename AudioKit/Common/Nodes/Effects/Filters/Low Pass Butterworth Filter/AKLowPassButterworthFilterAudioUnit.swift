// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKLowPassButterworthFilterAudioUnit: AKAudioUnitBase {

    let cutoffFrequency = AUParameter(
        identifier: "cutoffFrequency",
        name: "Cutoff Frequency (Hz)",
        address: AKLowPassButterworthFilterParameter.cutoffFrequency.rawValue,
        range: 12.0 ... 20_000.0,
        unit: .hertz,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createLowPassButterworthFilterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [cutoffFrequency])
    }
}
