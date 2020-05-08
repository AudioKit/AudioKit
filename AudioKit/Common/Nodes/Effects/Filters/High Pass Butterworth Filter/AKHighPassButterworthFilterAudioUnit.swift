// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKHighPassButterworthFilterAudioUnit: AKAudioUnitBase {

    private(set) var cutoffFrequency: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createHighPassButterworthFilterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        cutoffFrequency = AUParameter(
            identifier: "cutoffFrequency",
            name: "Cutoff Frequency (Hz)",
            address: AKHighPassButterworthFilterParameter.cutoffFrequency.rawValue,
            range: AKHighPassButterworthFilter.cutoffFrequencyRange,
            unit: .hertz,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [cutoffFrequency])

        cutoffFrequency.value = AUValue(AKHighPassButterworthFilter.defaultCutoffFrequency)
    }
}
