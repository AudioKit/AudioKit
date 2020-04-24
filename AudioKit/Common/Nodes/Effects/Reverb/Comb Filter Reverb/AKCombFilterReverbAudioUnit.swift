//
//  AKCombFilterReverbAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import AVFoundation

public class AKCombFilterReverbAudioUnit: AKAudioUnitBase {

    private(set) var reverbDuration: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createCombFilterReverbDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        reverbDuration = AUParameter(
            identifier: "reverbDuration",
            name: "Reverb Duration (Seconds)",
            address: AKCombFilterReverbParameter.reverbDuration.rawValue,
            range: AKCombFilterReverb.reverbDurationRange,
            unit: .seconds,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [reverbDuration])

        reverbDuration.value = AUValue(AKCombFilterReverb.defaultReverbDuration)
    }
}
