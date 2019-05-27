//
//  AKVariableDelayAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKVariableDelayAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKVariableDelayParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKVariableDelayParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var time: Double = AKVariableDelay.defaultTime {
        didSet { setParameter(.time, value: time) }
    }

    var feedback: Double = AKVariableDelay.defaultFeedback {
        didSet { setParameter(.feedback, value: feedback) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createVariableDelayDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)
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

        setParameterTree(AUParameterTree(children: [time, feedback]))
        time.value = Float(AKVariableDelay.defaultTime)
        feedback.value = Float(AKVariableDelay.defaultFeedback)
    }

    public override var canProcessInPlace: Bool { return true }

}
