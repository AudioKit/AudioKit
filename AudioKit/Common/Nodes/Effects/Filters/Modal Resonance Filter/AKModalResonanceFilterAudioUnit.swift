// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKModalResonanceFilterAudioUnit: AKAudioUnitBase {

    private(set) var frequency: AUParameter!

    private(set) var qualityFactor: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createModalResonanceFilterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        frequency = AUParameter(
            identifier: "frequency",
            name: "Resonant Frequency (Hz)",
            address: AKModalResonanceFilterParameter.frequency.rawValue,
            range: AKModalResonanceFilter.frequencyRange,
            unit: .hertz,
            flags: .default)
        qualityFactor = AUParameter(
            identifier: "qualityFactor",
            name: "Quality Factor",
            address: AKModalResonanceFilterParameter.qualityFactor.rawValue,
            range: AKModalResonanceFilter.qualityFactorRange,
            unit: .generic,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [frequency, qualityFactor])

        frequency.value = AUValue(AKModalResonanceFilter.defaultFrequency)
        qualityFactor.value = AUValue(AKModalResonanceFilter.defaultQualityFactor)
    }
}
