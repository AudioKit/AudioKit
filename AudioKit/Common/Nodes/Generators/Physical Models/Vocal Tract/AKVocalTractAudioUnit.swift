// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKVocalTractAudioUnit: AKAudioUnitBase {

    let frequency = AUParameter(
        identifier: "frequency",
        name: "Glottal frequency.",
        address: AKVocalTractParameter.frequency.rawValue,
        range: AKVocalTract.frequencyRange,
        unit: .hertz,
        flags: .default)

    let tonguePosition = AUParameter(
        identifier: "tonguePosition",
        name: "Tongue position (0-1)",
        address: AKVocalTractParameter.tonguePosition.rawValue,
        range: AKVocalTract.tonguePositionRange,
        unit: .generic,
        flags: .default)

    let tongueDiameter = AUParameter(
        identifier: "tongueDiameter",
        name: "Tongue diameter (0-1)",
        address: AKVocalTractParameter.tongueDiameter.rawValue,
        range: AKVocalTract.tongueDiameterRange,
        unit: .generic,
        flags: .default)

    let tenseness = AUParameter(
        identifier: "tenseness",
        name: "Vocal tenseness. 0 = all breath. 1=fully saturated.",
        address: AKVocalTractParameter.tenseness.rawValue,
        range: AKVocalTract.tensenessRange,
        unit: .generic,
        flags: .default)

    let nasality = AUParameter(
        identifier: "nasality",
        name: "Sets the velum size. Larger values of this creates more nasally sounds.",
        address: AKVocalTractParameter.nasality.rawValue,
        range: AKVocalTract.nasalityRange,
        unit: .generic,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createVocalTractDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [frequency,
                                                                  tonguePosition,
                                                                  tongueDiameter,
                                                                  tenseness,
                                                                  nasality])
    }
}
