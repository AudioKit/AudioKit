//
//  AKVocalTractAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKVocalTractAudioUnit: AKGeneratorAudioUnitBase {

    func setParameter(_ address: AKVocalTractParameter, value: Double) {
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKVocalTractParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    var frequency: Double = 160.0 {
        didSet { setParameter(.frequency, value: frequency) }
    }
    var tonguePosition: Double = 0.5 {
        didSet { setParameter(.tonguePosition, value: tonguePosition) }
    }
    var tongueDiameter: Double = 1.0 {
        didSet { setParameter(.tongueDiameter, value: tongueDiameter) }
    }
    var tenseness: Double = 0.6 {
        didSet { setParameter(.tenseness, value: tenseness) }
    }
    var nasality: Double = 0.0 {
        didSet { setParameter(.nasality, value: nasality) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createVocalTractDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let frequency = AUParameterTree.createParameter(
            withIdentifier: "frequency",
            name: "Glottal frequency.",
            address: AUParameterAddress(0),
            min: 0.0,
            max: 22_050.0,
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let tonguePosition = AUParameterTree.createParameter(
            withIdentifier: "tonguePosition",
            name: "Tongue position (0-1)",
            address: AUParameterAddress(1),
            min: 0.0,
            max: 1.0,
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let tongueDiameter = AUParameterTree.createParameter(
            withIdentifier: "tongueDiameter",
            name: "Tongue diameter (0-1)",
            address: AUParameterAddress(2),
            min: 0.0,
            max: 1.0,
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let tenseness = AUParameterTree.createParameter(
            withIdentifier: "tenseness",
            name: "Vocal tenseness. 0 = all breath. 1=fully saturated.",
            address: AUParameterAddress(3),
            min: 0.0,
            max: 1.0,
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let nasality = AUParameterTree.createParameter(
            withIdentifier: "nasality",
            name: "Sets the velum size. Larger values of this creates more nasally sounds.",
            address: AUParameterAddress(4),
            min: 0.0,
            max: 1.0,
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [frequency, tonguePosition, tongueDiameter, tenseness, nasality]))
        frequency.value = 160.0
        tonguePosition.value = 0.5
        tongueDiameter.value = 1.0
        tenseness.value = 0.6
        nasality.value = 0.0
    }

    public override var canProcessInPlace: Bool { return true } 

}
