//
//  AKDynamicRangeCompressorAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKDynamicRangeCompressorAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKDynamicRangeCompressorParameter, value: Double) {
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKDynamicRangeCompressorParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    var ratio: Double = AKDynamicRangeCompressor.defaultRatio {
        didSet { setParameter(.ratio, value: ratio) }
    }

    var threshold: Double = AKDynamicRangeCompressor.defaultThreshold {
        didSet { setParameter(.threshold, value: threshold) }
    }

    var attackTime: Double = AKDynamicRangeCompressor.defaultAttackTime {
        didSet { setParameter(.attackTime, value: attackTime) }
    }

    var releaseTime: Double = AKDynamicRangeCompressor.defaultReleaseTime {
        didSet { setParameter(.releaseTime, value: releaseTime) }
    }

    var rampTime: Double = 0.0 {
        didSet { setParameter(.rampTime, value: rampTime) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createDynamicRangeCompressorDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let ratio = AUParameterTree.createParameter(
            withIdentifier: "ratio",
            name: "Ratio to compress with, a value > 1 will compress",
            address: AUParameterAddress(0),
            min: Float(AKDynamicRangeCompressor.ratioRange.lowerBound),
            max: Float(AKDynamicRangeCompressor.ratioRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let threshold = AUParameterTree.createParameter(
            withIdentifier: "threshold",
            name: "Threshold (in dB) 0 = max",
            address: AUParameterAddress(1),
            min: Float(AKDynamicRangeCompressor.thresholdRange.lowerBound),
            max: Float(AKDynamicRangeCompressor.thresholdRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let attackTime = AUParameterTree.createParameter(
            withIdentifier: "attackTime",
            name: "Attack time",
            address: AUParameterAddress(2),
            min: Float(AKDynamicRangeCompressor.attackTimeRange.lowerBound),
            max: Float(AKDynamicRangeCompressor.attackTimeRange.upperBound),
            unit: .seconds,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let releaseTime = AUParameterTree.createParameter(
            withIdentifier: "releaseTime",
            name: "Release time",
            address: AUParameterAddress(3),
            min: Float(AKDynamicRangeCompressor.releaseTimeRange.lowerBound),
            max: Float(AKDynamicRangeCompressor.releaseTimeRange.upperBound),
            unit: .seconds,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [ratio, threshold, attackTime, releaseTime]))
        ratio.value = Float(AKDynamicRangeCompressor.defaultRatio)
        threshold.value = Float(AKDynamicRangeCompressor.defaultThreshold)
        attackTime.value = Float(AKDynamicRangeCompressor.defaultAttackTime)
        releaseTime.value = Float(AKDynamicRangeCompressor.defaultReleaseTime)
    }

    public override var canProcessInPlace: Bool { get { return true; }}

}
