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

        let centerFrequency = AUParameterTree.createParameter(
            withIdentifier: "centerFrequency",
            name: "Center Frequency (Hz)",
            address: AKEqualizerFilterParameter.centerFrequency.rawValue,
            min: Float(AKEqualizerFilter.centerFrequencyRange.lowerBound),
            max: Float(AKEqualizerFilter.centerFrequencyRange.upperBound),
            unit: .hertz,
            flags: .default)
        let bandwidth = AUParameterTree.createParameter(
            withIdentifier: "bandwidth",
            name: "Bandwidth (Hz)",
            address: AKEqualizerFilterParameter.bandwidth.rawValue,
            min: Float(AKEqualizerFilter.bandwidthRange.lowerBound),
            max: Float(AKEqualizerFilter.bandwidthRange.upperBound),
            unit: .hertz,
            flags: .default)
        let gain = AUParameterTree.createParameter(
            withIdentifier: "gain",
            name: "Gain (%)",
            address: AKEqualizerFilterParameter.gain.rawValue,
            min: Float(AKEqualizerFilter.gainRange.lowerBound),
            max: Float(AKEqualizerFilter.gainRange.upperBound),
            unit: .percent,
            flags: .default)
        
        setParameterTree(AUParameterTree.createTree(withChildren: [centerFrequency, bandwidth, gain]))
        centerFrequency.value = Float(AKEqualizerFilter.defaultCenterFrequency)
        bandwidth.value = Float(AKEqualizerFilter.defaultBandwidth)
        gain.value = Float(AKEqualizerFilter.defaultGain)
    }

    public override var canProcessInPlace: Bool { return true }

}
