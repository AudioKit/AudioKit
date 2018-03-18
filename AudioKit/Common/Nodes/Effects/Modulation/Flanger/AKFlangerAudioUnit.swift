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
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKModulatedDelayParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    var frequency: Double = Double(kAKFlanger_DefaultFrequency) {
        didSet { setParameter(.frequency, value: frequency) }
    }

    var depth: Double = Double(kAKFlanger_DefaultDepth) {
        didSet { setParameter(.depth, value: depth) }
    }

    var feedback: Double = Double(kAKFlanger_DefaultFeedback) {
        didSet { setParameter(.feedback, value: feedback) }
    }

    var dryWetMix: Double = Double(kAKFlanger_DefaultDryWetMix) {
        didSet { setParameter(.dryWetMix, value: dryWetMix) }
    }

    var rampTime: Double = 0.0 {
        didSet { setParameter(.rampTime, value: rampTime) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createFlangerDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let frequency = AUParameterTree.createParameter(
            withIdentifier: "frequency",
            name: "Frequency (Hz)",
            address: AUParameterAddress(0),
            min: kAKFlanger_MinFrequency,
            max: kAKFlanger_MaxFrequency,
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let depth = AUParameterTree.createParameter(
            withIdentifier: "depth",
            name: "Depth 0-1",
            address: AUParameterAddress(1),
            min: Float(0),
            max: Float(1),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let feedback = AUParameterTree.createParameter(
            withIdentifier: "feedback",
            name: "Feedback 0-1",
            address: AUParameterAddress(2),
            min: Float(0),
            max: Float(1),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let dryWetMix = AUParameterTree.createParameter(
            withIdentifier: "dryWetMix",
            name: "Dry Wet Mix 0-1",
            address: AUParameterAddress(3),
            min: Float(0),
            max: Float(2),
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [frequency, depth, feedback, dryWetMix]))
        frequency.value = kAKFlanger_DefaultFrequency
        depth.value = kAKFlanger_DefaultDepth
        feedback.value = kAKFlanger_DefaultFeedback
        dryWetMix.value = kAKFlanger_DefaultDryWetMix
    }

    public override var canProcessInPlace: Bool { get { return true; }}

}
