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
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKStringResonatorParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
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
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createStringResonatorDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let fundamentalFrequency = AUParameterTree.createParameter(
            withIdentifier: "fundamentalFrequency",
            name: "Fundamental Frequency (Hz)",
            address: AUParameterAddress(0),
            min: Float(AKStringResonator.fundamentalFrequencyRange.lowerBound),
            max: Float(AKStringResonator.fundamentalFrequencyRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let feedback = AUParameterTree.createParameter(
            withIdentifier: "feedback",
            name: "Feedback (%)",
            address: AUParameterAddress(1),
            min: Float(AKStringResonator.feedbackRange.lowerBound),
            max: Float(AKStringResonator.feedbackRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [fundamentalFrequency, feedback]))
        fundamentalFrequency.value = Float(AKStringResonator.defaultFundamentalFrequency)
        feedback.value = Float(AKStringResonator.defaultFeedback)
    }

    public override var canProcessInPlace: Bool { return true } 

}
