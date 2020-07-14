// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

public class AKFlangerAudioUnit: AKAudioUnitBase {

    var frequency = AUParameter(
        identifier: "frequency",
        name: "Frequency (Hz)",
        address: AKModulatedDelayParameter.frequency.rawValue,
        range: kAKFlanger_MinFrequency ... kAKFlanger_MaxFrequency,
        unit: .hertz,
        flags: .default)

    var depth = AUParameter(
       identifier: "depth",
       name: "Depth 0-1",
       address: AKModulatedDelayParameter.depth.rawValue,
       range: kAKFlanger_MinDepth ... kAKFlanger_MaxDepth,
       unit: .generic,
       flags: .default)

    var feedback = AUParameter(
       identifier: "feedback",
       name: "Feedback 0-1",
       address: AKModulatedDelayParameter.feedback.rawValue,
       range: kAKFlanger_MinFeedback ... kAKFlanger_MaxFeedback,
       unit: .generic,
       flags: .default)

    var dryWetMix = AUParameter(
       identifier: "dryWetMix",
       name: "Dry Wet Mix 0-1",
       address: AKModulatedDelayParameter.dryWetMix.rawValue,
       range: kAKFlanger_MinDryWetMix ... kAKFlanger_MaxDryWetMix,
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
