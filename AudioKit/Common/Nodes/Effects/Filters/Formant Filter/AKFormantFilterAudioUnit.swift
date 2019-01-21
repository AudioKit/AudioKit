//
//  AKFormantFilterAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKFormantFilterAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKFormantFilterParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKFormantFilterParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var centerFrequency: Double = AKFormantFilter.defaultCenterFrequency {
        didSet { setParameter(.centerFrequency, value: centerFrequency) }
    }

    var attackDuration: Double = AKFormantFilter.defaultAttackDuration {
        didSet { setParameter(.attackDuration, value: attackDuration) }
    }

    var decayDuration: Double = AKFormantFilter.defaultDecayDuration {
        didSet { setParameter(.decayDuration, value: decayDuration) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createFormantFilterDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let centerFrequency = AUParameter(
            identifier: "centerFrequency",
            name: "Center Frequency (Hz)",
            address: AKFormantFilterParameter.centerFrequency.rawValue,
            range: AKFormantFilter.centerFrequencyRange,
            unit: .hertz,
            flags: .default)
        let attackDuration = AUParameter(
            identifier: "attackDuration",
            name: "Impulse response attack time (Seconds)",
            address: AKFormantFilterParameter.attackDuration.rawValue,
            range: AKFormantFilter.attackDurationRange,
            unit: .seconds,
            flags: .default)
        let decayDuration = AUParameter(
            identifier: "decayDuration",
            name: "Impulse reponse decay time (Seconds)",
            address: AKFormantFilterParameter.decayDuration.rawValue,
            range: AKFormantFilter.decayDurationRange,
            unit: .seconds,
            flags: .default)

        setParameterTree(AUParameterTree(children: [centerFrequency, attackDuration, decayDuration]))
        centerFrequency.value = Float(AKFormantFilter.defaultCenterFrequency)
        attackDuration.value = Float(AKFormantFilter.defaultAttackDuration)
        decayDuration.value = Float(AKFormantFilter.defaultDecayDuration)
    }

    public override var canProcessInPlace: Bool { return true }

}
