//
//  AKFlangerAudioUnit.swift
//  AudioKit
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKFlangerAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKModulatedDelayParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKModulatedDelayParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var frequency: Double = AKFlanger.defaultFrequency {
        didSet { setParameter(.frequency, value: frequency) }
    }

    var depth: Double = AKFlanger.defaultDepth {
        didSet { setParameter(.depth, value: depth) }
    }

    var feedback: Double = AKFlanger.defaultFeedback {
        didSet { setParameter(.feedback, value: feedback) }
    }

    var dryWetMix: Double = AKFlanger.defaultDryWetMix {
        didSet { setParameter(.dryWetMix, value: dryWetMix) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createFlangerDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let frequency = AUParameter(
            identifier: "frequency",
            name: "Frequency (Hz)",
            address: AKModulatedDelayParameter.frequency.rawValue,
            range: AKFlanger.frequencyRange,
            unit: .hertz,
            flags: .default)
        let depth = AUParameter(
            identifier: "depth",
            name: "Depth 0-1",
            address: AKModulatedDelayParameter.depth.rawValue,
            range: AKFlanger.depthRange,
            unit: .generic,
            flags: .default)
        let feedback = AUParameter(
            identifier: "feedback",
            name: "Feedback 0-1",
            address: AKModulatedDelayParameter.feedback.rawValue,
            range: AKFlanger.feedbackRange,
            unit: .generic,
            flags: .default)
        let dryWetMix = AUParameter(
            identifier: "dryWetMix",
            name: "Dry Wet Mix 0-1",
            address: AKModulatedDelayParameter.dryWetMix.rawValue,
            range: AKFlanger.dryWetMixRange,
            unit: .generic,
            flags: .default)

        setParameterTree(AUParameterTree(children: [frequency, depth, feedback, dryWetMix]))
        frequency.value = Float(AKFlanger.defaultFrequency)
        depth.value = Float(AKFlanger.defaultDepth)
        feedback.value = Float(AKFlanger.defaultFeedback)
        dryWetMix.value = Float(AKFlanger.defaultDryWetMix)
    }

    public override var canProcessInPlace: Bool { return true }

}
