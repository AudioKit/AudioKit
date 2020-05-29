// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKVariableDelayAudioUnit: AKAudioUnitBase {

    let time = AUParameter(
        identifier: "time",
        name: "Delay time (Seconds)",
        address: AKVariableDelayParameter.time.rawValue,
        range: AKVariableDelay.timeRange,
        unit: .seconds,
        flags: .default)

    let feedback = AUParameter(
        identifier: "feedback",
        name: "Feedback (%)",
        address: AKVariableDelayParameter.feedback.rawValue,
        range: AKVariableDelay.feedbackRange,
        unit: .generic,
        flags: .default)

    public override func createDSP() -> AKDSPRef {
        return createVariableDelayDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        parameterTree = AUParameterTree.createTree(withChildren: [time, feedback])
    }
}
