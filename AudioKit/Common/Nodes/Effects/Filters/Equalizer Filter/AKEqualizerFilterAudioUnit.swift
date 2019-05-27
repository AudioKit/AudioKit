//
//  AKEqualizerFilterAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKEqualizerFilterAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKEqualizerFilterParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKEqualizerFilterParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var centerFrequency: Double = AKEqualizerFilter.defaultCenterFrequency {
        didSet { setParameter(.centerFrequency, value: centerFrequency) }
    }

    var bandwidth: Double = AKEqualizerFilter.defaultBandwidth {
        didSet { setParameter(.bandwidth, value: bandwidth) }
    }

    var gain: Double = AKEqualizerFilter.defaultGain {
        didSet { setParameter(.gain, value: gain) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createEqualizerFilterDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let centerFrequency = AUParameter(
            identifier: "centerFrequency",
            name: "Center Frequency (Hz)",
            address: AKEqualizerFilterParameter.centerFrequency.rawValue,
            range: AKEqualizerFilter.centerFrequencyRange,
            unit: .hertz,
            flags: .default)
        let bandwidth = AUParameter(
            identifier: "bandwidth",
            name: "Bandwidth (Hz)",
            address: AKEqualizerFilterParameter.bandwidth.rawValue,
            range: AKEqualizerFilter.bandwidthRange,
            unit: .hertz,
            flags: .default)
        let gain = AUParameter(
            identifier: "gain",
            name: "Gain (%)",
            address: AKEqualizerFilterParameter.gain.rawValue,
            range: AKEqualizerFilter.gainRange,
            unit: .percent,
            flags: .default)

        setParameterTree(AUParameterTree(children: [centerFrequency, bandwidth, gain]))
        centerFrequency.value = Float(AKEqualizerFilter.defaultCenterFrequency)
        bandwidth.value = Float(AKEqualizerFilter.defaultBandwidth)
        gain.value = Float(AKEqualizerFilter.defaultGain)
    }

    public override var canProcessInPlace: Bool { return true }

}
