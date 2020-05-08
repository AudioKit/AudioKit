// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKLowPassButterworthFilterAudioUnit: AKAudioUnitBase {

    private(set) var cutoffFrequency: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createLowPassButterworthFilterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        cutoffFrequency = AUParameter(
            identifier: "cutoffFrequency",
            name: "Cutoff Frequency (Hz)",
            address: AKLowPassButterworthFilterParameter.cutoffFrequency.rawValue,
            range: AKLowPassButterworthFilter.cutoffFrequencyRange,
            unit: .hertz,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [cutoffFrequency])

        cutoffFrequency.value = AUValue(AKLowPassButterworthFilter.defaultCutoffFrequency)
    }
}
