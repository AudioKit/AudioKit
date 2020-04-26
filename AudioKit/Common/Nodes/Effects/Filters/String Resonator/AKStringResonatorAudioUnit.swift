// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKStringResonatorAudioUnit: AKAudioUnitBase {

    private(set) var fundamentalFrequency: AUParameter!

    private(set) var feedback: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createStringResonatorDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        fundamentalFrequency = AUParameter(
            identifier: "fundamentalFrequency",
            name: "Fundamental Frequency (Hz)",
            address: AKStringResonatorParameter.fundamentalFrequency.rawValue,
            range: AKStringResonator.fundamentalFrequencyRange,
            unit: .hertz,
            flags: .default)
        feedback = AUParameter(
            identifier: "feedback",
            name: "Feedback (%)",
            address: AKStringResonatorParameter.feedback.rawValue,
            range: AKStringResonator.feedbackRange,
            unit: .generic,
            flags: .default)

        parameterTree = AUParameterTree.createTree(withChildren: [fundamentalFrequency, feedback])

        fundamentalFrequency.value = AUValue(AKStringResonator.defaultFundamentalFrequency)
        feedback.value = AUValue(AKStringResonator.defaultFeedback)
    }
}
