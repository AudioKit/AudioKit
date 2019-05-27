//
//  AKAmplitudeEnvelopeAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKAmplitudeEnvelopeAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKAmplitudeEnvelopeParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKAmplitudeEnvelopeParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var attackDuration: Double = AKAmplitudeEnvelope.defaultAttackDuration {
        didSet { setParameter(.attackDuration, value: attackDuration) }
    }

    var decayDuration: Double = AKAmplitudeEnvelope.defaultDecayDuration {
        didSet { setParameter(.decayDuration, value: decayDuration) }
    }

    var sustainLevel: Double = AKAmplitudeEnvelope.defaultSustainLevel {
        didSet { setParameter(.sustainLevel, value: sustainLevel) }
    }

    var releaseDuration: Double = AKAmplitudeEnvelope.defaultReleaseDuration {
        didSet { setParameter(.releaseDuration, value: releaseDuration) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createAmplitudeEnvelopeDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let attackDuration = AUParameter(
            identifier: "attackDuration",
            name: "Attack time",
            address: AKAmplitudeEnvelopeParameter.attackDuration.rawValue,
            range: AKAmplitudeEnvelope.attackDurationRange,
            unit: .seconds,
            flags: .default)
        let decayDuration = AUParameter(
            identifier: "decayDuration",
            name: "Decay time",
            address: AKAmplitudeEnvelopeParameter.decayDuration.rawValue,
            range: AKAmplitudeEnvelope.decayDurationRange,
            unit: .seconds,
            flags: .default)
        let sustainLevel = AUParameter(
            identifier: "sustainLevel",
            name: "Sustain Level",
            address: AKAmplitudeEnvelopeParameter.sustainLevel.rawValue,
            range: AKAmplitudeEnvelope.sustainLevelRange,
            unit: .generic,
            flags: .default)
        let releaseDuration = AUParameter(
            identifier: "releaseDuration",
            name: "Release time",
            address: AKAmplitudeEnvelopeParameter.releaseDuration.rawValue,
            range: AKAmplitudeEnvelope.releaseDurationRange,
            unit: .seconds,
            flags: .default)

        setParameterTree(AUParameterTree(children: [attackDuration, decayDuration, sustainLevel, releaseDuration]))
        attackDuration.value = Float(AKAmplitudeEnvelope.defaultAttackDuration)
        decayDuration.value = Float(AKAmplitudeEnvelope.defaultDecayDuration)
        sustainLevel.value = Float(AKAmplitudeEnvelope.defaultSustainLevel)
        releaseDuration.value = Float(AKAmplitudeEnvelope.defaultReleaseDuration)
    }

    public override var canProcessInPlace: Bool { return true }

}
