// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKAmplitudeEnvelopeAudioUnit: AKAudioUnitBase {

    private(set) var attackDuration: AUParameter!

    private(set) var decayDuration: AUParameter!

    private(set) var sustainLevel: AUParameter!

    private(set) var releaseDuration: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createAmplitudeEnvelopeDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        attackDuration = AUParameter(
            identifier: "attackDuration",
            name: "Attack time",
            address: AKAmplitudeEnvelopeParameter.attackDuration.rawValue,
            range: AKAmplitudeEnvelope.attackDurationRange,
            unit: .seconds,
            flags: .default)
        decayDuration = AUParameter(
            identifier: "decayDuration",
            name: "Decay time",
            address: AKAmplitudeEnvelopeParameter.decayDuration.rawValue,
            range: AKAmplitudeEnvelope.decayDurationRange,
            unit: .seconds,
            flags: .default)
        sustainLevel = AUParameter(
            identifier: "sustainLevel",
            name: "Sustain Level",
            address: AKAmplitudeEnvelopeParameter.sustainLevel.rawValue,
            range: AKAmplitudeEnvelope.sustainLevelRange,
            unit: .generic,
            flags: .default)
        releaseDuration = AUParameter(
            identifier: "releaseDuration",
            name: "Release time",
            address: AKAmplitudeEnvelopeParameter.releaseDuration.rawValue,
            range: AKAmplitudeEnvelope.releaseDurationRange,
            unit: .seconds,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [attackDuration, decayDuration, sustainLevel, releaseDuration])

        attackDuration.value = AUValue(AKAmplitudeEnvelope.defaultAttackDuration)
        decayDuration.value = AUValue(AKAmplitudeEnvelope.defaultDecayDuration)
        sustainLevel.value = AUValue(AKAmplitudeEnvelope.defaultSustainLevel)
        releaseDuration.value = AUValue(AKAmplitudeEnvelope.defaultReleaseDuration)
    }
}
