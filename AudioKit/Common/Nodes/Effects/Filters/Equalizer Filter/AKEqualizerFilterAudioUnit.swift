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
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKEqualizerFilterParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
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
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createEqualizerFilterDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let centerFrequency = AUParameterTree.createParameter(
            withIdentifier: "centerFrequency",
            name: "Center Frequency (Hz)",
            address: AUParameterAddress(0),
            min: Float(AKEqualizerFilter.centerFrequencyRange.lowerBound),
            max: Float(AKEqualizerFilter.centerFrequencyRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let bandwidth = AUParameterTree.createParameter(
            withIdentifier: "bandwidth",
            name: "Bandwidth (Hz)",
            address: AUParameterAddress(1),
            min: Float(AKEqualizerFilter.bandwidthRange.lowerBound),
            max: Float(AKEqualizerFilter.bandwidthRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let gain = AUParameterTree.createParameter(
            withIdentifier: "gain",
            name: "Gain (%)",
            address: AUParameterAddress(2),
            min: Float(AKEqualizerFilter.gainRange.lowerBound),
            max: Float(AKEqualizerFilter.gainRange.upperBound),
            unit: .percent,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [centerFrequency, bandwidth, gain]))
        centerFrequency.value = Float(AKEqualizerFilter.defaultCenterFrequency)
        bandwidth.value = Float(AKEqualizerFilter.defaultBandwidth)
        gain.value = Float(AKEqualizerFilter.defaultGain)
    }

    public override var canProcessInPlace: Bool { return true } 

}
