//
//  AKStereoDelayAudioUnit.swift
//  AudioKit
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKStereoDelayAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKStereoDelayParameter, value: Double) {
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKStereoDelayParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    var time: Double = AKStereoDelay.defaultTime {
        didSet { setParameter(.time, value: time) }
    }

    var feedback: Double = AKStereoDelay.defaultFeedback {
        didSet { setParameter(.feedback, value: feedback) }
    }

    var dryWetMix: Double = AKStereoDelay.defaultDryWetMix {
        didSet { setParameter(.dryWetMix, value: dryWetMix) }
    }

    var pingPong: Bool = false {
        didSet { setParameter(.pingPong, value: pingPong ? 1.0 : 0.0) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createStereoDelayDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let time = AUParameterTree.createParameter(
            withIdentifier: "time",
            name: "Delay time (Seconds)",
            address: AUParameterAddress(0),
            min: Float(AKStereoDelay.timeRange.lowerBound),
            max: Float(AKStereoDelay.timeRange.upperBound),
            unit: .seconds,
            unitName: nil,
            flags: [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp],
            valueStrings: nil,
            dependentParameters: nil
        )
        let feedback = AUParameterTree.createParameter(
            withIdentifier: "feedback",
            name: "Feedback (%)",
            address: AUParameterAddress(1),
            min: Float(AKStereoDelay.feedbackRange.lowerBound),
            max: Float(AKStereoDelay.feedbackRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp],
            valueStrings: nil,
            dependentParameters: nil
        )
        let dryWetMix = AUParameterTree.createParameter(
            withIdentifier: "dryWetMix",
            name: "Dry-Wet Mix",
            address: AUParameterAddress(2),
            min: Float(AKStereoDelay.dryWetMixRange.lowerBound),
            max: Float(AKStereoDelay.dryWetMixRange.upperBound),
            unit: .generic,
            unitName: nil,
            flags: [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp],
            valueStrings: nil,
            dependentParameters: nil
        )
        let pingPong = AUParameterTree.createParameter(
            withIdentifier: "pingPong",
            name: "Ping-Pong Mode",
            address: AUParameterAddress(3),
            min: Float(0.0),
            max: Float(1.0),
            unit: .boolean,
            unitName: nil,
            flags: [.flag_IsReadable, .flag_IsWritable],
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [time, feedback, dryWetMix, pingPong]))
        time.value = Float(AKStereoDelay.defaultTime)
        feedback.value = Float(AKStereoDelay.defaultFeedback)
        dryWetMix.value = Float(AKStereoDelay.defaultDryWetMix)
        pingPong.value = 0.0
    }

    public override var canProcessInPlace: Bool { return true }

}
