//
//  AKBandRejectButterworthFilterAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import AVFoundation

public class AKBandRejectButterworthFilterAudioUnit: AKAudioUnitBase {

    private(set) var centerFrequency: AUParameter!

    private(set) var bandwidth: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createBandRejectButterworthFilterDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        centerFrequency = AUParameter(
            identifier: "centerFrequency",
            name: "Center Frequency (Hz)",
            address: AKBandRejectButterworthFilterParameter.centerFrequency.rawValue,
            range: AKBandRejectButterworthFilter.centerFrequencyRange,
            unit: .hertz,
            flags: .default)
        bandwidth = AUParameter(
            identifier: "bandwidth",
            name: "Bandwidth (Hz)",
            address: AKBandRejectButterworthFilterParameter.bandwidth.rawValue,
            range: AKBandRejectButterworthFilter.bandwidthRange,
            unit: .hertz,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [centerFrequency, bandwidth])

        centerFrequency.value = AUValue(AKBandRejectButterworthFilter.defaultCenterFrequency)
        bandwidth.value = AUValue(AKBandRejectButterworthFilter.defaultBandwidth)
    }
}
