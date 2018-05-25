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
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKCostelloReverbParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
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
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createCostelloReverbDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let feedback = AUParameterTree.createParameter(
            withIdentifier: "feedback",
            name: "Feedback",
            address: AUParameterAddress(0),
            min: Float(AKCostelloReverb.feedbackRange.lowerBound),
            max: Float(AKCostelloReverb.feedbackRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let cutoffFrequency = AUParameterTree.createParameter(
            withIdentifier: "cutoffFrequency",
            name: "Cutoff Frequency",
            address: AUParameterAddress(1),
            min: Float(AKCostelloReverb.cutoffFrequencyRange.lowerBound),
            max: Float(AKCostelloReverb.cutoffFrequencyRange.upperBound),
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [feedback, cutoffFrequency]))
        feedback.value = Float(AKCostelloReverb.defaultFeedback)
        cutoffFrequency.value = Float(AKCostelloReverb.defaultCutoffFrequency)
    }

    public override var canProcessInPlace: Bool { return true } 

}
