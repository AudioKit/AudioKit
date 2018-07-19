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
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKLowShelfParametricEqualizerFilterParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
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
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createLowShelfParametricEqualizerFilterDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let cornerFrequency = AUParameterTree.createParameter(
            withIdentifier: "cornerFrequency",
            name: "Corner Frequency (Hz)",
            address: AUParameterAddress(0),
            min: Float(AKLowShelfParametricEqualizerFilter.cornerFrequencyRange.lowerBound),
            max: Float(AKLowShelfParametricEqualizerFilter.cornerFrequencyRange.upperBound),
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
            min: Float(AKLowShelfParametricEqualizerFilter.gainRange.lowerBound),
            max: Float(AKLowShelfParametricEqualizerFilter.gainRange.upperBound),
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
            min: Float(AKLowShelfParametricEqualizerFilter.qRange.lowerBound),
            max: Float(AKLowShelfParametricEqualizerFilter.qRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [cornerFrequency, gain, q]))
        cornerFrequency.value = Float(AKLowShelfParametricEqualizerFilter.defaultCornerFrequency)
        gain.value = Float(AKLowShelfParametricEqualizerFilter.defaultGain)
        q.value = Float(AKLowShelfParametricEqualizerFilter.defaultQ)
    }

    public override var canProcessInPlace: Bool { return true } 

}
