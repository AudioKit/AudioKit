//
//  AKClipperAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import AVFoundation

public class AKClipperAudioUnit: AKAudioUnitBase {

    private(set) var limit: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createClipperDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        limit = AUParameter(
            identifier: "limit",
            name: "Threshold",
            address: AKClipperParameter.limit.rawValue,
            range: AKClipper.limitRange,
            unit: .generic,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [limit])

        limit.value = AUValue(AKClipper.defaultLimit)
    }
}
