//
//  AKResonantFilterAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKResonantFilterAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKResonantFilterParameter, value: Double) {
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKResonantFilterParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    var frequency: Double = AKResonantFilter.defaultFrequency {
        didSet { setParameter(.frequency, value: frequency) }
    }

    var bandwidth: Double = AKResonantFilter.defaultBandwidth {
        didSet { setParameter(.bandwidth, value: bandwidth) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createResonantFilterDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let frequency = AUParameterTree.createParameter(
            withIdentifier: "frequency",
            name: "Center frequency of the filter, or frequency position of the peak response.",
            address: AUParameterAddress(0),
            min: Float(AKResonantFilter.frequencyRange.lowerBound),
            max: Float(AKResonantFilter.frequencyRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let bandwidth = AUParameterTree.createParameter(
            withIdentifier: "bandwidth",
            name: "Bandwidth of the filter.",
            address: AUParameterAddress(1),
            min: Float(AKResonantFilter.bandwidthRange.lowerBound),
            max: Float(AKResonantFilter.bandwidthRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [frequency, bandwidth]))
        frequency.value = Float(AKResonantFilter.defaultFrequency)
        bandwidth.value = Float(AKResonantFilter.defaultBandwidth)
    }

    public override var canProcessInPlace: Bool { return true } 

}
