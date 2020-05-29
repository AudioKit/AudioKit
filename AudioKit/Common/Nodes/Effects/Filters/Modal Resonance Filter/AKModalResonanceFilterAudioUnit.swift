// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKModalResonanceFilterAudioUnit: AKAudioUnitBase {

    let frequency = AUParameter(
        identifier: "frequency",
        name: "Resonant Frequency (Hz)",
        address: AKModalResonanceFilterParameter.frequency.rawValue,
        range: AKModalResonanceFilter.frequencyRange,
        unit: .hertz,
        flags: .default)

    let qualityFactor = AUParameter(
        identifier: "qualityFactor",
        name: "Quality Factor",
        address: AKModalResonanceFilterParameter.qualityFactor.rawValue,
        range: AKModalResonanceFilter.qualityFactorRange,
        unit: .generic,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createModalResonanceFilterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [frequency, qualityFactor])
    }
}
