//
//  AKHighShelfParametricEqualizerFilterAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKHighShelfParametricEqualizerFilterAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKHighShelfParametricEqualizerFilterParameter, value: Double) {
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKHighShelfParametricEqualizerFilterParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    var centerFrequency: Double = AKHighShelfParametricEqualizerFilter.defaultCenterFrequency {
        didSet { setParameter(.centerFrequency, value: centerFrequency) }
    }

    var gain: Double = AKHighShelfParametricEqualizerFilter.defaultGain {
        didSet { setParameter(.gain, value: gain) }
    }

    var q: Double = AKHighShelfParametricEqualizerFilter.defaultQ {
        didSet { setParameter(.Q, value: q) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createHighShelfParametricEqualizerFilterDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let centerFrequency = AUParameterTree.createParameter(
            withIdentifier: "centerFrequency",
            name: "Corner Frequency (Hz)",
            address: AUParameterAddress(0),
            min: Float(AKHighShelfParametricEqualizerFilter.centerFrequencyRange.lowerBound),
            max: Float(AKHighShelfParametricEqualizerFilter.centerFrequencyRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let gain = AUParameterTree.createParameter(
            withIdentifier: "gain",
            name: "Gain",
            address: AUParameterAddress(1),
            min: Float(AKHighShelfParametricEqualizerFilter.gainRange.lowerBound),
            max: Float(AKHighShelfParametricEqualizerFilter.gainRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let q = AUParameterTree.createParameter(
            withIdentifier: "q",
            name: "Q",
            address: AUParameterAddress(2),
            min: Float(AKHighShelfParametricEqualizerFilter.qRange.lowerBound),
            max: Float(AKHighShelfParametricEqualizerFilter.qRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [centerFrequency, gain, q]))
        centerFrequency.value = Float(AKHighShelfParametricEqualizerFilter.defaultCenterFrequency)
        gain.value = Float(AKHighShelfParametricEqualizerFilter.defaultGain)
        q.value = Float(AKHighShelfParametricEqualizerFilter.defaultQ)
    }

    public override var canProcessInPlace: Bool { return true } 

}
