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
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKPeakingParametricEqualizerFilterParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
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
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createPeakingParametricEqualizerFilterDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let centerFrequency = AUParameterTree.createParameter(
            withIdentifier: "centerFrequency",
            name: "Center Frequency (Hz)",
            address: AUParameterAddress(0),
            min: Float(AKPeakingParametricEqualizerFilter.centerFrequencyRange.lowerBound),
            max: Float(AKPeakingParametricEqualizerFilter.centerFrequencyRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let gain = AUParameterTree.createParameter(
            withIdentifier: "gain",
            name: "Gain",
            address: AUParameterAddress(1),
            min: Float(AKPeakingParametricEqualizerFilter.gainRange.lowerBound),
            max: Float(AKPeakingParametricEqualizerFilter.gainRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let q = AUParameterTree.createParameter(
            withIdentifier: "q",
            name: "Q",
            address: AUParameterAddress(2),
            min: Float(AKPeakingParametricEqualizerFilter.qRange.lowerBound),
            max: Float(AKPeakingParametricEqualizerFilter.qRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [centerFrequency, gain, q]))
        centerFrequency.value = Float(AKPeakingParametricEqualizerFilter.defaultCenterFrequency)
        gain.value = Float(AKPeakingParametricEqualizerFilter.defaultGain)
        q.value = Float(AKPeakingParametricEqualizerFilter.defaultQ)
    }

    public override var canProcessInPlace: Bool { return true } 

}
