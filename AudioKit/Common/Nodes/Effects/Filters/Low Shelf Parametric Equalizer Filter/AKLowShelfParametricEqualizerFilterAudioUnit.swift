//
//  AKLowShelfParametricEqualizerFilterAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKLowShelfParametricEqualizerFilterAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKLowShelfParametricEqualizerFilterParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKLowShelfParametricEqualizerFilterParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var cornerFrequency: Double = AKLowShelfParametricEqualizerFilter.defaultCornerFrequency {
        didSet { setParameter(.cornerFrequency, value: cornerFrequency) }
    }

    var gain: Double = AKLowShelfParametricEqualizerFilter.defaultGain {
        didSet { setParameter(.gain, value: gain) }
    }

    var q: Double = AKLowShelfParametricEqualizerFilter.defaultQ {
        didSet { setParameter(.Q, value: q) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createLowShelfParametricEqualizerFilterDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let cornerFrequency = AUParameter(
            identifier: "cornerFrequency",
            name: "Corner Frequency (Hz)",
            address: AKLowShelfParametricEqualizerFilterParameter.cornerFrequency.rawValue,
            range: AKLowShelfParametricEqualizerFilter.cornerFrequencyRange,
            unit: .hertz,
            flags: .default)
        let gain = AUParameter(
            identifier: "gain",
            name: "Gain",
            address: AKLowShelfParametricEqualizerFilterParameter.gain.rawValue,
            range: AKLowShelfParametricEqualizerFilter.gainRange,
            unit: .generic,
            flags: .default)
        let q = AUParameter(
            identifier: "q",
            name: "Q",
            address: AKLowShelfParametricEqualizerFilterParameter.Q.rawValue,
            range: AKLowShelfParametricEqualizerFilter.qRange,
            unit: .generic,
            flags: .default)

        setParameterTree(AUParameterTree(children: [cornerFrequency, gain, q]))
        cornerFrequency.value = Float(AKLowShelfParametricEqualizerFilter.defaultCornerFrequency)
        gain.value = Float(AKLowShelfParametricEqualizerFilter.defaultGain)
        q.value = Float(AKLowShelfParametricEqualizerFilter.defaultQ)
    }

    public override var canProcessInPlace: Bool { return true }

}
