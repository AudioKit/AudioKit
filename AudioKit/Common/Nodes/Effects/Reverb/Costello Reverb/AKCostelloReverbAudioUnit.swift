//
//  AKCostelloReverbAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKCostelloReverbAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKCostelloReverbParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKCostelloReverbParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var feedback: Double = AKCostelloReverb.defaultFeedback {
        didSet { setParameter(.feedback, value: feedback) }
    }

    var cutoffFrequency: Double = AKCostelloReverb.defaultCutoffFrequency {
        didSet { setParameter(.cutoffFrequency, value: cutoffFrequency) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createCostelloReverbDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let feedback = AUParameter(
            identifier: "feedback",
            name: "Feedback",
            address: AKCostelloReverbParameter.feedback.rawValue,
            range: AKCostelloReverb.feedbackRange,
            unit: .generic,
            flags: .default)
        let cutoffFrequency = AUParameter(
            identifier: "cutoffFrequency",
            name: "Cutoff Frequency",
            address: AKCostelloReverbParameter.cutoffFrequency.rawValue,
            range: AKCostelloReverb.cutoffFrequencyRange,
            unit: .hertz,
            flags: .default)

        setParameterTree(AUParameterTree(children: [feedback, cutoffFrequency]))
        feedback.value = Float(AKCostelloReverb.defaultFeedback)
        cutoffFrequency.value = Float(AKCostelloReverb.defaultCutoffFrequency)
    }

    public override var canProcessInPlace: Bool { return true }

}
