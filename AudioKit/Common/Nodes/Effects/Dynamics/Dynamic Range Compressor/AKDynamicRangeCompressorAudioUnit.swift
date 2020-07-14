// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

public class AKDynamicRangeCompressorAudioUnit: AKAudioUnitBase {

    let ratio = AUParameter(
        identifier: "ratio",
        name: "Ratio to compress with, a value > 1 will compress",
        address: AKDynamicRangeCompressorParameter.ratio.rawValue,
        range: 0.01 ... 100.0,
        unit: .hertz,
        flags: .default)

    let threshold = AUParameter(
        identifier: "threshold",
        name: "Threshold (in dB) 0 = max",
        address: AKDynamicRangeCompressorParameter.threshold.rawValue,
        range: -100.0 ... 0.0,
        unit: .generic,
        flags: .default)

    let attackDuration = AUParameter(
        identifier: "attackDuration",
        name: "Attack duration",
        address: AKDynamicRangeCompressorParameter.attackDuration.rawValue,
        range: 0.0 ... 1.0,
        unit: .seconds,
        flags: .default)

    let releaseDuration = AUParameter(
        identifier: "releaseDuration",
        name: "Release duration",
        address: AKDynamicRangeCompressorParameter.releaseDuration.rawValue,
        range: 0.0 ... 1.0,
        unit: .seconds,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createDynamicRangeCompressorDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [ratio, threshold, attackDuration, releaseDuration])
    }
}
