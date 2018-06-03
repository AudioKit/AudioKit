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
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKBandRejectButterworthFilterParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
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
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createBandRejectButterworthFilterDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let centerFrequency = AUParameterTree.createParameter(
            withIdentifier: "centerFrequency",
            name: "Center Frequency (Hz)",
            address: AUParameterAddress(0),
            min: Float(AKBandRejectButterworthFilter.centerFrequencyRange.lowerBound),
            max: Float(AKBandRejectButterworthFilter.centerFrequencyRange.upperBound),
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
            min: Float(AKBandRejectButterworthFilter.bandwidthRange.lowerBound),
            max: Float(AKBandRejectButterworthFilter.bandwidthRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [centerFrequency, bandwidth]))
        centerFrequency.value = Float(AKBandRejectButterworthFilter.defaultCenterFrequency)
        bandwidth.value = Float(AKBandRejectButterworthFilter.defaultBandwidth)
    }

    public override var canProcessInPlace: Bool { return true } 

}
