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
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKAmplitudeEnvelopeParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    var attackDuration: Double = 0.1 {
        didSet { setParameter(.attackDuration, value: attackDuration) }
    }
    var decayDuration: Double = 0.1 {
        didSet { setParameter(.decayDuration, value: decayDuration) }
    }
    var sustainLevel: Double = 1.0 {
        didSet { setParameter(.sustainLevel, value: sustainLevel) }
    }
    var releaseDuration: Double = 0.1 {
        didSet { setParameter(.releaseDuration, value: releaseDuration) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createAmplitudeEnvelopeDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let attackDuration = AUParameterTree.createParameter(
            withIdentifier: "attackDuration",
            name: "Attack duration (secs)",
            address: AUParameterAddress(0),
            min: 0,
            max: 99,
            unit: .seconds,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let decayDuration = AUParameterTree.createParameter(
            withIdentifier: "decayDuration",
            name: "Decay duration (secs)",
            address: AUParameterAddress(1),
            min: 0,
            max: 99,
            unit: .seconds,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let sustainLevel = AUParameterTree.createParameter(
            withIdentifier: "sustainLevel",
            name: "Sustain Level",
            address: AUParameterAddress(2),
            min: 0,
            max: 99,
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let releaseDuration = AUParameterTree.createParameter(
            withIdentifier: "releaseDuration",
            name: "Release duration (secs)",
            address: AUParameterAddress(3),
            min: 0,
            max: 99,
            unit: .seconds,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [attackDuration, decayDuration, sustainLevel, releaseDuration]))
        attackDuration.value = 0.1
        decayDuration.value = 0.1
        sustainLevel.value = 1.0
        releaseDuration.value = 0.1
    }

    public override var canProcessInPlace: Bool { return true } 

}
