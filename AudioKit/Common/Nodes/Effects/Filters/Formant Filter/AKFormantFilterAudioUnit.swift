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
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKFormantFilterParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
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
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createFormantFilterDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let centerFrequency = AUParameterTree.createParameter(
            withIdentifier: "centerFrequency",
            name: "Center Frequency (Hz)",
            address: AUParameterAddress(0),
            min: Float(AKFormantFilter.centerFrequencyRange.lowerBound),
            max: Float(AKFormantFilter.centerFrequencyRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let attackDuration = AUParameterTree.createParameter(
            withIdentifier: "attackDuration",
            name: "Impulse response attack duration (Seconds)",
            address: AUParameterAddress(1),
            min: Float(AKFormantFilter.attackDurationRange.lowerBound),
            max: Float(AKFormantFilter.attackDurationRange.upperBound),
            unit: .seconds,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let decayDuration = AUParameterTree.createParameter(
            withIdentifier: "decayDuration",
            name: "Impulse reponse decay duration (Seconds)",
            address: AUParameterAddress(2),
            min: Float(AKFormantFilter.decayDurationRange.lowerBound),
            max: Float(AKFormantFilter.decayDurationRange.upperBound),
            unit: .seconds,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [centerFrequency, attackDuration, decayDuration]))
        centerFrequency.value = Float(AKFormantFilter.defaultCenterFrequency)
        attackDuration.value = Float(AKFormantFilter.defaultAttackDuration)
        decayDuration.value = Float(AKFormantFilter.defaultDecayDuration)
    }

    public override var canProcessInPlace: Bool { return true } 

}
