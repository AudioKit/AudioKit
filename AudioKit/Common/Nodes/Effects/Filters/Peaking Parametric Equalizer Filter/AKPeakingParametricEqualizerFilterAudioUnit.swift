//
//  AKPeakingParametricEqualizerFilterAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKPeakingParametricEqualizerFilterAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKPeakingParametricEqualizerFilterParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKPeakingParametricEqualizerFilterParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var centerFrequency: Double = AKPeakingParametricEqualizerFilter.defaultCenterFrequency {
        didSet { setParameter(.centerFrequency, value: centerFrequency) }
    }

    var gain: Double = AKPeakingParametricEqualizerFilter.defaultGain {
        didSet { setParameter(.gain, value: gain) }
    }

    var q: Double = AKPeakingParametricEqualizerFilter.defaultQ {
        didSet { setParameter(.Q, value: q) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createPeakingParametricEqualizerFilterDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let centerFrequency = AUParameter(
            identifier: "centerFrequency",
            name: "Center Frequency (Hz)",
            address: AKPeakingParametricEqualizerFilterParameter.centerFrequency.rawValue,
            range: AKPeakingParametricEqualizerFilter.centerFrequencyRange,
            unit: .hertz,
            flags: .default)
        let gain = AUParameter(
            identifier: "gain",
            name: "Gain",
            address: AKPeakingParametricEqualizerFilterParameter.gain.rawValue,
            range: AKPeakingParametricEqualizerFilter.gainRange,
            unit: .generic,
            flags: .default)
        let q = AUParameter(
            identifier: "q",
            name: "Q",
            address: AKPeakingParametricEqualizerFilterParameter.Q.rawValue,
            range: AKPeakingParametricEqualizerFilter.qRange,
            unit: .generic,
            flags: .default)

        setParameterTree(AUParameterTree(children: [centerFrequency, gain, q]))
        centerFrequency.value = Float(AKPeakingParametricEqualizerFilter.defaultCenterFrequency)
        gain.value = Float(AKPeakingParametricEqualizerFilter.defaultGain)
        q.value = Float(AKPeakingParametricEqualizerFilter.defaultQ)
    }

    public override var canProcessInPlace: Bool { return true }

}
