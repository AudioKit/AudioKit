//
//  AKBandRejectButterworthFilterAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKBandRejectButterworthFilterAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKBandRejectButterworthFilterParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKBandRejectButterworthFilterParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var centerFrequency: Double = AKBandRejectButterworthFilter.defaultCenterFrequency {
        didSet { setParameter(.centerFrequency, value: centerFrequency) }
    }

    var bandwidth: Double = AKBandRejectButterworthFilter.defaultBandwidth {
        didSet { setParameter(.bandwidth, value: bandwidth) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createBandRejectButterworthFilterDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let centerFrequency = AUParameter(
            identifier: "centerFrequency",
            name: "Center Frequency (Hz)",
            address: AKBandRejectButterworthFilterParameter.centerFrequency.rawValue,
            range: AKBandRejectButterworthFilter.centerFrequencyRange,
            unit: .hertz,
            flags: .default)
        let bandwidth = AUParameter(
            identifier: "bandwidth",
            name: "Bandwidth (Hz)",
            address: AKBandRejectButterworthFilterParameter.bandwidth.rawValue,
            range: AKBandRejectButterworthFilter.bandwidthRange,
            unit: .hertz,
            flags: .default)

        setParameterTree(AUParameterTree(children: [centerFrequency, bandwidth]))
        centerFrequency.value = Float(AKBandRejectButterworthFilter.defaultCenterFrequency)
        bandwidth.value = Float(AKBandRejectButterworthFilter.defaultBandwidth)
    }

    public override var canProcessInPlace: Bool { return true }

}
