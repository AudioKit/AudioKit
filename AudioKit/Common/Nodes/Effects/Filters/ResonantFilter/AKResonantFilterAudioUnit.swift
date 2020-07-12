// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKResonantFilterAudioUnit: AKAudioUnitBase {

    let frequency = AUParameter(
        identifier: "frequency",
        name: "Center frequency of the filter, or frequency position of the peak response.",
        address: AKResonantFilterParameter.frequency.rawValue,
        range: 100.0 ... 20_000.0,
        unit: .hertz,
        flags: .default)

    let bandwidth = AUParameter(
        identifier: "bandwidth",
        name: "Bandwidth of the filter.",
        address: AKResonantFilterParameter.bandwidth.rawValue,
        range: 0.0 ... 10_000.0,
        unit: .hertz,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createResonantFilterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [frequency, bandwidth])
    }
}
