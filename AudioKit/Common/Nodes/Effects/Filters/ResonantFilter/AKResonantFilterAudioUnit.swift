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
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKResonantFilterParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
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
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createResonantFilterDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let frequency = AUParameterTree.createParameter(
            withIdentifier: "frequency",
            name: "Center frequency of the filter, or frequency position of the peak response.",
            address: AKResonantFilterParameter.frequency.rawValue,
            min: Float(AKResonantFilter.frequencyRange.lowerBound),
            max: Float(AKResonantFilter.frequencyRange.upperBound),
            unit: .hertz,
            flags: .default)
        let bandwidth = AUParameterTree.createParameter(
            withIdentifier: "bandwidth",
            name: "Bandwidth of the filter.",
            address: AKResonantFilterParameter.bandwidth.rawValue,
            min: Float(AKResonantFilter.bandwidthRange.lowerBound),
            max: Float(AKResonantFilter.bandwidthRange.upperBound),
            unit: .hertz,
            flags: .default)
        
        setParameterTree(AUParameterTree.createTree(withChildren: [frequency, bandwidth]))
        frequency.value = Float(AKResonantFilter.defaultFrequency)
        bandwidth.value = Float(AKResonantFilter.defaultBandwidth)
    }

    public override var canProcessInPlace: Bool { return true }

}
