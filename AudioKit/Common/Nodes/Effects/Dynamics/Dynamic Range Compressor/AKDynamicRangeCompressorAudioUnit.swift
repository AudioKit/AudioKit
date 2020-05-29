// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKDynamicRangeCompressorAudioUnit: AKAudioUnitBase {

    let ratio = AUParameter(
        identifier: "ratio",
        name: "Ratio to compress with, a value > 1 will compress",
        address: AKDynamicRangeCompressorParameter.ratio.rawValue,
        range: AKDynamicRangeCompressor.ratioRange,
        unit: .hertz,
        flags: .default)

    let threshold = AUParameter(
        identifier: "threshold",
        name: "Threshold (in dB) 0 = max",
        address: AKDynamicRangeCompressorParameter.threshold.rawValue,
        range: AKDynamicRangeCompressor.thresholdRange,
        unit: .generic,
        flags: .default)

    let attackTime = AUParameter(
        identifier: "attackTime",
        name: "Attack time",
        address: AKDynamicRangeCompressorParameter.attackTime.rawValue,
        range: AKDynamicRangeCompressor.attackDurationRange,
        unit: .seconds,
        flags: .default)

    let releaseTime = AUParameter(
        identifier: "releaseTime",
        name: "Release time",
        address: AKDynamicRangeCompressorParameter.releaseTime.rawValue,
        range: AKDynamicRangeCompressor.releaseDurationRange,
        unit: .seconds,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createDynamicRangeCompressorDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [ratio, threshold, attackTime, releaseTime])
    }
}
