// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

public class AKAmplitudeEnvelopeAudioUnit: AKAudioUnitBase {

    let attackDuration = AUParameter(
        identifier: "attackDuration",
        name: "Attack time",
        address: AKAmplitudeEnvelopeParameter.attackDuration.rawValue,
        range: 0 ... 99,
        unit: .seconds,
        flags: .default)

    let decayDuration = AUParameter(
        identifier: "decayDuration",
        name: "Decay time",
        address: AKAmplitudeEnvelopeParameter.decayDuration.rawValue,
        range: 0 ... 99,
        unit: .seconds,
        flags: .default)

    let sustainLevel = AUParameter(
        identifier: "sustainLevel",
        name: "Sustain Level",
        address: AKAmplitudeEnvelopeParameter.sustainLevel.rawValue,
        range: 0 ... 99,
        unit: .generic,
        flags: .default)

    let releaseDuration = AUParameter(
        identifier: "releaseDuration",
        name: "Release time",
        address: AKAmplitudeEnvelopeParameter.releaseDuration.rawValue,
        range: 0 ... 99,
        unit: .seconds,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createAmplitudeEnvelopeDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [attackDuration,
                                                                  decayDuration,
                                                                  sustainLevel,
                                                                  releaseDuration])
    }
}
