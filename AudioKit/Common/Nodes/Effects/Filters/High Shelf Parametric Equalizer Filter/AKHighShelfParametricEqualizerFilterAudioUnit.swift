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
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKHighShelfParametricEqualizerFilterParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
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
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createHighShelfParametricEqualizerFilterDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let centerFrequency = AUParameterTree.createParameter(
            withIdentifier: "centerFrequency",
            name: "Corner Frequency (Hz)",
            address: AKHighShelfParametricEqualizerFilterParameter.centerFrequency.rawValue,
            min: Float(AKHighShelfParametricEqualizerFilter.centerFrequencyRange.lowerBound),
            max: Float(AKHighShelfParametricEqualizerFilter.centerFrequencyRange.upperBound),
            unit: .hertz,
            flags: .default)
        let gain = AUParameterTree.createParameter(
            withIdentifier: "gain",
            name: "Gain",
            address: AKHighShelfParametricEqualizerFilterParameter.gain.rawValue,
            min: Float(AKHighShelfParametricEqualizerFilter.gainRange.lowerBound),
            max: Float(AKHighShelfParametricEqualizerFilter.gainRange.upperBound),
            unit: .generic,
            flags: .default)
        let q = AUParameterTree.createParameter(
            withIdentifier: "q",
            name: "Q",
            address: AKHighShelfParametricEqualizerFilterParameter.Q.rawValue,
            min: Float(AKHighShelfParametricEqualizerFilter.qRange.lowerBound),
            max: Float(AKHighShelfParametricEqualizerFilter.qRange.upperBound),
            unit: .generic,
            flags: .default)
        
        setParameterTree(AUParameterTree.createTree(withChildren: [centerFrequency, gain, q]))
        centerFrequency.value = Float(AKHighShelfParametricEqualizerFilter.defaultCenterFrequency)
        gain.value = Float(AKHighShelfParametricEqualizerFilter.defaultGain)
        q.value = Float(AKHighShelfParametricEqualizerFilter.defaultQ)
    }

    public override var canProcessInPlace: Bool { return true }

}
