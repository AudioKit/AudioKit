//
//  AKResonantFilterAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import AVFoundation

public class AKResonantFilterAudioUnit: AKAudioUnitBase {

    private(set) var frequency: AUParameter!

    private(set) var bandwidth: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createResonantFilterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        frequency = AUParameter(
            identifier: "frequency",
            name: "Center frequency of the filter, or frequency position of the peak response.",
            address: AKResonantFilterParameter.frequency.rawValue,
            range: AKResonantFilter.frequencyRange,
            unit: .hertz,
            flags: .default)
        bandwidth = AUParameter(
            identifier: "bandwidth",
            name: "Bandwidth of the filter.",
            address: AKResonantFilterParameter.bandwidth.rawValue,
            range: AKResonantFilter.bandwidthRange,
            unit: .hertz,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [frequency, bandwidth])

        frequency.value = AUValue(AKResonantFilter.defaultFrequency)
        bandwidth.value = AUValue(AKResonantFilter.defaultBandwidth)
    }
}
