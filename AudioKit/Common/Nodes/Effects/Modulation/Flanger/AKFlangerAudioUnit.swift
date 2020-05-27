// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKFlangerAudioUnit: AKAudioUnitBase {

    var frequency = AUParameter(
        identifier: "frequency",
        name: "Frequency (Hz)",
        address: AKModulatedDelayParameter.frequency.rawValue,
        range: AKFlanger.frequencyRange,
        unit: .hertz,
        flags: .default)

    var depth = AUParameter(
       identifier: "depth",
       name: "Depth 0-1",
       address: AKModulatedDelayParameter.depth.rawValue,
       range: AKFlanger.depthRange,
       unit: .generic,
       flags: .default)

    var feedback = AUParameter(
       identifier: "feedback",
       name: "Feedback 0-1",
       address: AKModulatedDelayParameter.feedback.rawValue,
       range: AKFlanger.feedbackRange,
       unit: .generic,
       flags: .default)

    var dryWetMix = AUParameter(
       identifier: "dryWetMix",
       name: "Dry Wet Mix 0-1",
       address: AKModulatedDelayParameter.dryWetMix.rawValue,
       range: AKFlanger.dryWetMixRange,
       unit: .generic,
       flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createFlangerDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [frequency, depth, feedback, dryWetMix])
    }
}
