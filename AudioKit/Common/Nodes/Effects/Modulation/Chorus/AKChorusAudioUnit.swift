//
//  AKChorusAudioUnit.swift
//  AudioKit
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKChorusAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKModulatedDelayParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKModulatedDelayParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var frequency: Double = AKChorus.defaultFrequency {
        didSet { setParameter(.frequency, value: frequency) }
    }

    var depth: Double = AKChorus.defaultDepth {
        didSet { setParameter(.depth, value: depth) }
    }

    var feedback: Double = AKChorus.defaultFeedback {
        didSet { setParameter(.feedback, value: feedback) }
    }

    var dryWetMix: Double = AKChorus.defaultDryWetMix {
        didSet { setParameter(.dryWetMix, value: dryWetMix) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createChorusDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let frequency = AUParameter(
            identifier: "frequency",
            name: "Frequency (Hz)",
            address: AKModulatedDelayParameter.frequency.rawValue,
            range: AKChorus.frequencyRange,
            unit: .hertz,
            flags: .default)
        let depth = AUParameter(
            identifier: "depth",
            name: "Depth 0-1",
            address: AKModulatedDelayParameter.depth.rawValue,
            range: AKChorus.depthRange,
            unit: .generic,
            flags: .default)
        let feedback = AUParameter(
            identifier: "feedback",
            name: "Feedback 0-1",
            address: AKModulatedDelayParameter.feedback.rawValue,
            range: AKChorus.feedbackRange,
            unit: .generic,
            flags: .default)
        let dryWetMix = AUParameter(
            identifier: "dryWetMix",
            name: "Dry Wet Mix 0-1",
            address: AKModulatedDelayParameter.dryWetMix.rawValue,
            range: AKChorus.dryWetMixRange,
            unit: .generic,
            flags: .default)

        setParameterTree(AUParameterTree(children: [frequency, depth, feedback, dryWetMix]))
        frequency.value = Float(AKChorus.defaultFrequency)
        depth.value = Float(AKChorus.defaultDepth)
        feedback.value = Float(AKChorus.defaultFeedback)
        dryWetMix.value = Float(AKChorus.defaultDryWetMix)
    }

    public override var canProcessInPlace: Bool { return true }

}
