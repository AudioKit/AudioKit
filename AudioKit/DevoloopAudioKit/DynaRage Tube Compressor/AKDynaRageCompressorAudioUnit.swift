// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

public class AKDynaRageCompressorAudioUnit: AKAudioUnitBase {

    let ratio = AUParameter(
        identifier: "ratio",
        name: "Ratio to compress with, a value > 1 will compress",
        address: AKDynaRageCompressorParameter.ratio.rawValue,
        range: 1.0 ... 20.0,
        unit: .generic,
        flags: .default)

    let threshold = AUParameter(
        identifier: "threshold",
        name: "Threshold (in dB) 0 = max",
        address: AKDynaRageCompressorParameter.threshold.rawValue,
        range: -100.0 ... 0.0,
        unit: .decibels,
        flags: .default)

    let attack = AUParameter(
        identifier: "attackDuration",
        name: "Attack Duration",
        address: AKDynaRageCompressorParameter.attack.rawValue,
        range: 0.1 ... 500.0,
        unit: .seconds,
        flags: .default)

    let release = AUParameter(
        identifier: "releaseDuration",
        name: "Release Duration",
        address: AKDynaRageCompressorParameter.release.rawValue,
        range: 1.0 ... 20.0,
        unit: .seconds,
        flags: .default)

    let rageAmount = AUParameter(
        identifier: "rageAmount",
        name: "Rage Amount",
        address: AKDynaRageCompressorParameter.rageAmount.rawValue,
        range: 0.1 ... 20.0,
        unit: .generic,
        flags: .default)

    let rageEnabled = AUParameter(
        identifier: "rageEnabled",
        name: "Rage Enabled",
        address: AKDynaRageCompressorParameter.rageEnabled.rawValue,
        range: 0.0 ... 1.0,
        unit: .boolean,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createDynaRageCompressorDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [ratio,
                                                                  threshold,
                                                                  attack,
                                                                  release,
                                                                  rageAmount,
                                                                  rageEnabled])
    }
}
