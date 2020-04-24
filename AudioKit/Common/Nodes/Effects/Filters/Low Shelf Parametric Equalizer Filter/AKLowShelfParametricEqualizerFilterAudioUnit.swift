//
//  AKLowShelfParametricEqualizerFilterAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import AVFoundation

public class AKLowShelfParametricEqualizerFilterAudioUnit: AKAudioUnitBase {

    private(set) var cornerFrequency: AUParameter!

    private(set) var gain: AUParameter!

    private(set) var q: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createLowShelfParametricEqualizerFilterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        cornerFrequency = AUParameter(
            identifier: "cornerFrequency",
            name: "Corner Frequency (Hz)",
            address: AKLowShelfParametricEqualizerFilterParameter.cornerFrequency.rawValue,
            range: AKLowShelfParametricEqualizerFilter.cornerFrequencyRange,
            unit: .hertz,
            flags: .default)
        gain = AUParameter(
            identifier: "gain",
            name: "Gain",
            address: AKLowShelfParametricEqualizerFilterParameter.gain.rawValue,
            range: AKLowShelfParametricEqualizerFilter.gainRange,
            unit: .generic,
            flags: .default)
        q = AUParameter(
            identifier: "q",
            name: "Q",
            address: AKLowShelfParametricEqualizerFilterParameter.Q.rawValue,
            range: AKLowShelfParametricEqualizerFilter.qRange,
            unit: .generic,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [cornerFrequency, gain, q])

        cornerFrequency.value = AUValue(AKLowShelfParametricEqualizerFilter.defaultCornerFrequency)
        gain.value = AUValue(AKLowShelfParametricEqualizerFilter.defaultGain)
        q.value = AUValue(AKLowShelfParametricEqualizerFilter.defaultQ)
    }
}
