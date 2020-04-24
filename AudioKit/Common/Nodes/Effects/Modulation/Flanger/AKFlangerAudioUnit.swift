//
//  AKFlangerAudioUnit.swift
//  AudioKit
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKFlangerAudioUnit: AKAudioUnitBase {

    var frequency: AUParameter!

    var depth: AUParameter!

    var feedback: AUParameter!

    var dryWetMix: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createFlangerDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        frequency = AUParameter(
            identifier: "frequency",
            name: "Frequency (Hz)",
            address: AKModulatedDelayParameter.frequency.rawValue,
            range: AKFlanger.frequencyRange,
            unit: .hertz,
            flags: .default)
        depth = AUParameter(
            identifier: "depth",
            name: "Depth 0-1",
            address: AKModulatedDelayParameter.depth.rawValue,
            range: AKFlanger.depthRange,
            unit: .generic,
            flags: .default)
        feedback = AUParameter(
            identifier: "feedback",
            name: "Feedback 0-1",
            address: AKModulatedDelayParameter.feedback.rawValue,
            range: AKFlanger.feedbackRange,
            unit: .generic,
            flags: .default)
        dryWetMix = AUParameter(
            identifier: "dryWetMix",
            name: "Dry Wet Mix 0-1",
            address: AKModulatedDelayParameter.dryWetMix.rawValue,
            range: AKFlanger.dryWetMixRange,
            unit: .generic,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [frequency, depth, feedback, dryWetMix])
        
        frequency.value = Float(AKFlanger.defaultFrequency)
        depth.value = Float(AKFlanger.defaultDepth)
        feedback.value = Float(AKFlanger.defaultFeedback)
        dryWetMix.value = Float(AKFlanger.defaultDryWetMix)
    }
}
