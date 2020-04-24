//
//  AKFaderAudioUnit.swift
//  AudioKit
//
//  Created by Ryan Francesconi, revision history on Github.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import AVFoundation

public class AKFaderAudioUnit: AKAudioUnitBase {
    
    var taper: AUParameter!

    var skew: AUParameter!

    var offset: AUParameter!

    var leftGain: AUParameter!

    var rightGain: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createFaderDSP()
    }

    public override init(
        componentDescription: AudioComponentDescription,
        options: AudioComponentInstantiationOptions = []
    ) throws {
        try super.init(componentDescription: componentDescription, options: options)

        leftGain = AUParameter(
            identifier: "leftGain",
            name: "Left Gain",
            address: 0,
            range: 0.0 ... 2.0,
            unit: .linearGain,
            flags: .default
        )

        rightGain = AUParameter(
            identifier: "rightGain",
            name: "Right Gain",
            address: 1,
            range: 0.0 ... 2.0,
            unit: .linearGain,
            flags: .default
        )

        taper = AUParameter(
            identifier: "taper",
            name: "Taper",
            address: 2,
            range: 0.1 ... 10.0,
            unit: .generic,
            flags: .default
        )

        skew = AUParameter(
            identifier: "skew",
            name: "Skew",
            address: 3,
            range: 0.0 ... 1.0,
            unit: .generic,
            flags: .default
        )

        offset = AUParameter(
            identifier: "offset",
            name: "Offset",
            address: 4,
            range: 0.0 ... 1000000000.0,
            unit: .generic,
            flags: .default
        )

        parameterTree = AUParameterTree.createTree(withChildren: [leftGain, rightGain, taper, skew, offset])
        
        leftGain.value = 1.0
        rightGain.value = 1.0
        taper.value = 1.0
        skew.value = 0.0
        offset.value = 0.0
    }
}
