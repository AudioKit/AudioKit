//
//  AKStringResonatorAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKStringResonatorAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKStringResonatorParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKStringResonatorParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var fundamentalFrequency: Double = AKStringResonator.defaultFundamentalFrequency {
        didSet { setParameter(.fundamentalFrequency, value: fundamentalFrequency) }
    }

    var feedback: Double = AKStringResonator.defaultFeedback {
        didSet { setParameter(.feedback, value: feedback) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createStringResonatorDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let fundamentalFrequency = AUParameter(
            identifier: "fundamentalFrequency",
            name: "Fundamental Frequency (Hz)",
            address: AKStringResonatorParameter.fundamentalFrequency.rawValue,
            range: AKStringResonator.fundamentalFrequencyRange,
            unit: .hertz,
            flags: .default)
        let feedback = AUParameter(
            identifier: "feedback",
            name: "Feedback (%)",
            address: AKStringResonatorParameter.feedback.rawValue,
            range: AKStringResonator.feedbackRange,
            unit: .generic,
            flags: .default)

        setParameterTree(AUParameterTree(children: [fundamentalFrequency, feedback]))
        fundamentalFrequency.value = Float(AKStringResonator.defaultFundamentalFrequency)
        feedback.value = Float(AKStringResonator.defaultFeedback)
    }

    public override var canProcessInPlace: Bool { return true }

}
