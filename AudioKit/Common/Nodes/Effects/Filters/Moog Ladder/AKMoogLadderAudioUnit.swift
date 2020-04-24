//
//  AKMoogLadderAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import AVFoundation

public class AKMoogLadderAudioUnit: AKAudioUnitBase {

    private(set) var cutoffFrequency: AUParameter!

    private(set) var resonance: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createMoogLadderDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        cutoffFrequency = AUParameter(
            identifier: "cutoffFrequency",
            name: "Cutoff Frequency (Hz)",
            address: AKMoogLadderParameter.cutoffFrequency.rawValue,
            range: AKMoogLadder.cutoffFrequencyRange,
            unit: .hertz,
            flags: .default)
        resonance = AUParameter(
            identifier: "resonance",
            name: "Resonance (%)",
            address: AKMoogLadderParameter.resonance.rawValue,
            range: AKMoogLadder.resonanceRange,
            unit: .percent,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [cutoffFrequency, resonance])

        cutoffFrequency.value = AUValue(AKMoogLadder.defaultCutoffFrequency)
        resonance.value = AUValue(AKMoogLadder.defaultResonance)
    }
}
