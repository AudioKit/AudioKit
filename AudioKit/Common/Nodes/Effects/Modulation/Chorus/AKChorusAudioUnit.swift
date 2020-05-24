// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKChorusAudioUnit: AKAudioUnitBase {

    private(set) var frequency: AUParameter!

    private(set) var depth: AUParameter!

    private(set) var feedback: AUParameter!

    private(set) var dryWetMix: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createChorusDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        frequency = AUParameter(
            identifier: "frequency",
            name: "Frequency (Hz)",
            address: AKModulatedDelayParameter.frequency.rawValue,
            range: AKChorus.frequencyRange,
            unit: .hertz,
            flags: .default)
        depth = AUParameter(
            identifier: "depth",
            name: "Depth 0-1",
            address: AKModulatedDelayParameter.depth.rawValue,
            range: AKChorus.depthRange,
            unit: .generic,
            flags: .default)
        feedback = AUParameter(
            identifier: "feedback",
            name: "Feedback 0-1",
            address: AKModulatedDelayParameter.feedback.rawValue,
            range: AKChorus.feedbackRange,
            unit: .generic,
            flags: .default)
        dryWetMix = AUParameter(
            identifier: "dryWetMix",
            name: "Dry Wet Mix 0-1",
            address: AKModulatedDelayParameter.dryWetMix.rawValue,
            range: AKChorus.dryWetMixRange,
            unit: .generic,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [frequency, depth, feedback, dryWetMix])

        frequency.value = AUValue(AKChorus.defaultFrequency)
        depth.value = AUValue(AKChorus.defaultDepth)
        feedback.value = AUValue(AKChorus.defaultFeedback)
        dryWetMix.value = AUValue(AKChorus.defaultDryWetMix)
    }
}
