// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class AKStereoDelayAudioUnit: AKAudioUnitBase {

    var time: AUParameter!

    var feedback: AUParameter!

    var dryWetMix: AUParameter!

    var pingPong: AUParameter!

    public override func createDSP() -> AKDSPRef {
        return createStereoDelayDSP()
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)
        time = AUParameter(
            identifier: "time",
            name: "Delay time (Seconds)",
            address: AKStereoDelayParameter.time.rawValue,
            range: AKStereoDelay.timeRange,
            unit: .seconds,
            flags: .default)
        feedback = AUParameter(
            identifier: "feedback",
            name: "Feedback (%)",
            address: AKStereoDelayParameter.feedback.rawValue,
            range: AKStereoDelay.feedbackRange,
            unit: .generic,
            flags: .default)
        dryWetMix = AUParameter(
            identifier: "dryWetMix",
            name: "Dry-Wet Mix",
            address: AKStereoDelayParameter.dryWetMix.rawValue,
            range: AKStereoDelay.dryWetMixRange,
            unit: .generic,
            flags: .default)
        pingPong = AUParameter(
            identifier: "pingPong",
            name: "Ping-Pong Mode",
            address: AKStereoDelayParameter.pingPong.rawValue,
            range: 0.0...1.0,
            unit: .boolean,
            flags: [.flag_IsReadable, .flag_IsWritable])

        parameterTree = AUParameterTree.createTree(withChildren: [time, feedback, dryWetMix, pingPong])

        time.value = Float(AKStereoDelay.defaultTime)
        feedback.value = Float(AKStereoDelay.defaultFeedback)
        dryWetMix.value = Float(AKStereoDelay.defaultDryWetMix)
        pingPong.value = 0.0
    }
}
