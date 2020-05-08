// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKVariableDelayAudioUnit: AKAudioUnitBase {

    private(set) var time: AUParameter!

    private(set) var feedback: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createVariableDelayDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        time = AUParameter(
            identifier: "time",
            name: "Delay time (Seconds)",
            address: AKVariableDelayParameter.time.rawValue,
            range: AKVariableDelay.timeRange,
            unit: .seconds,
            flags: .default)
        feedback = AUParameter(
            identifier: "feedback",
            name: "Feedback (%)",
            address: AKVariableDelayParameter.feedback.rawValue,
            range: AKVariableDelay.feedbackRange,
            unit: .generic,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [time, feedback])

        time.value = AUValue(AKVariableDelay.defaultTime)
        feedback.value = AUValue(AKVariableDelay.defaultFeedback)
    }
}
