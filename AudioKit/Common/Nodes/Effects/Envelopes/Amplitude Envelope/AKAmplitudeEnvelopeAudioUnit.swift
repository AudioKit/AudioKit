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

        let attackDuration = AUParameterTree.createParameter(
            identifier: "attackDuration",
            name: "Attack time",
            address: AKAmplitudeEnvelopeParameter.attackDuration.rawValue,
            min: Float(AKAmplitudeEnvelope.attackDurationRange.lowerBound),
            max: Float(AKAmplitudeEnvelope.attackDurationRange.upperBound),
            unit: .seconds,
            flags: .default)
        let decayDuration = AUParameterTree.createParameter(
            identifier: "decayDuration",
            name: "Decay time",
            address: AKAmplitudeEnvelopeParameter.decayDuration.rawValue,
            min: Float(AKAmplitudeEnvelope.decayDurationRange.lowerBound),
            max: Float(AKAmplitudeEnvelope.decayDurationRange.upperBound),
            unit: .seconds,
            flags: .default)
        let sustainLevel = AUParameterTree.createParameter(
            identifier: "sustainLevel",
            name: "Sustain Level",
            address: AKAmplitudeEnvelopeParameter.sustainLevel.rawValue,
            min: Float(AKAmplitudeEnvelope.sustainLevelRange.lowerBound),
            max: Float(AKAmplitudeEnvelope.sustainLevelRange.upperBound),
            unit: .generic,
            flags: .default)
        let releaseDuration = AUParameterTree.createParameter(
            identifier: "releaseDuration",
            name: "Release time",
            address: AKAmplitudeEnvelopeParameter.releaseDuration.rawValue,
            min: Float(AKAmplitudeEnvelope.releaseDurationRange.lowerBound),
            max: Float(AKAmplitudeEnvelope.releaseDurationRange.upperBound),
            unit: .seconds,
            flags: .default)
        
        setParameterTree(AUParameterTree.createTree(withChildren: [attackDuration, decayDuration, sustainLevel, releaseDuration]))
        attackDuration.value = Float(AKAmplitudeEnvelope.defaultAttackDuration)
        decayDuration.value = Float(AKAmplitudeEnvelope.defaultDecayDuration)
        sustainLevel.value = Float(AKAmplitudeEnvelope.defaultSustainLevel)
        releaseDuration.value = Float(AKAmplitudeEnvelope.defaultReleaseDuration)
    }

    public override var canProcessInPlace: Bool { return true }

}
