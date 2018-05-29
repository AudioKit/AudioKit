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
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKVariableDelayParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
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
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createVariableDelayDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let time = AUParameterTree.createParameter(
            withIdentifier: "time",
            name: "Delay time (Seconds)",
            address: AUParameterAddress(0),
            min: Float(AKVariableDelay.timeRange.lowerBound),
            max: Float(AKVariableDelay.timeRange.upperBound),
            unit: .seconds,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let feedback = AUParameterTree.createParameter(
            withIdentifier: "feedback",
            name: "Feedback (%)",
            address: AUParameterAddress(1),
            min: Float(AKVariableDelay.feedbackRange.lowerBound),
            max: Float(AKVariableDelay.feedbackRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [time, feedback]))
        time.value = Float(AKVariableDelay.defaultTime)
        feedback.value = Float(AKVariableDelay.defaultFeedback)
    }

    public override var canProcessInPlace: Bool { return true } 

}
