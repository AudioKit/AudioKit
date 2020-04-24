//
//  AKEqualizerFilterAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import AVFoundation

public class AKEqualizerFilterAudioUnit: AKAudioUnitBase {

    private(set) var centerFrequency: AUParameter!

    private(set) var bandwidth: AUParameter!

    private(set) var gain: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createEqualizerFilterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        centerFrequency = AUParameter(
            identifier: "centerFrequency",
            name: "Center Frequency (Hz)",
            address: AKEqualizerFilterParameter.centerFrequency.rawValue,
            range: AKEqualizerFilter.centerFrequencyRange,
            unit: .hertz,
            flags: .default)
        bandwidth = AUParameter(
            identifier: "bandwidth",
            name: "Bandwidth (Hz)",
            address: AKEqualizerFilterParameter.bandwidth.rawValue,
            range: AKEqualizerFilter.bandwidthRange,
            unit: .hertz,
            flags: .default)
        gain = AUParameter(
            identifier: "gain",
            name: "Gain (%)",
            address: AKEqualizerFilterParameter.gain.rawValue,
            range: AKEqualizerFilter.gainRange,
            unit: .percent,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [centerFrequency, bandwidth, gain])

        centerFrequency.value = AUValue(AKEqualizerFilter.defaultCenterFrequency)
        bandwidth.value = AUValue(AKEqualizerFilter.defaultBandwidth)
        gain.value = AUValue(AKEqualizerFilter.defaultGain)
    }
}
