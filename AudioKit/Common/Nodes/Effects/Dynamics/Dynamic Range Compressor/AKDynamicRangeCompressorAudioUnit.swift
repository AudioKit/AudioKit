// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKDynamicRangeCompressorAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKDynamicRangeCompressorParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKDynamicRangeCompressorParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var ratio: Double = AKDynamicRangeCompressor.defaultRatio {
        didSet { setParameter(.ratio, value: ratio) }
    }

    var threshold: Double = AKDynamicRangeCompressor.defaultThreshold {
        didSet { setParameter(.threshold, value: threshold) }
    }

    var attackDuration: Double = AKDynamicRangeCompressor.defaultAttackDuration {
        didSet { setParameter(.attackDuration, value: attackDuration) }
    }

    var releaseDuration: Double = AKDynamicRangeCompressor.defaultReleaseDuration {
        didSet { setParameter(.releaseDuration, value: releaseDuration) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    var compressionAmount: Float {
        get { parameter(withAddress: AKDynamicRangeCompressorParameter.compressionAmount.rawValue) }
    }

    public override func createDSP() -> AKDSPRef {
        return createDynamicRangeCompressorDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

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
        let attackDuration = AUParameter(
            identifier: "attackDuration",
            name: "Attack duration",
            address: AKDynamicRangeCompressorParameter.attackDuration.rawValue,
            range: AKDynamicRangeCompressor.attackDurationRange,
            unit: .seconds,
            flags: .default)
        let releaseDuration = AUParameter(
            identifier: "releaseDuration",
            name: "Release duration",
            address: 3,
            range: AKDynamicRangeCompressor.releaseDurationRange,
            unit: .seconds,
            flags: .default)

        setParameterTree(AUParameterTree(children: [ratio, threshold, attackDuration, releaseDuration]))
        ratio.value = Float(AKDynamicRangeCompressor.defaultRatio)
        threshold.value = Float(AKDynamicRangeCompressor.defaultThreshold)
        attackDuration.value = Float(AKDynamicRangeCompressor.defaultAttackDuration)
        releaseDuration.value = Float(AKDynamicRangeCompressor.defaultReleaseDuration)
    }

    public override var canProcessInPlace: Bool { return true }

}
