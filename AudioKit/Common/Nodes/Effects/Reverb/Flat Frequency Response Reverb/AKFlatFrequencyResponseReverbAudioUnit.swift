//
//  AKFlatFrequencyResponseReverbAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKFlatFrequencyResponseReverbAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKFlatFrequencyResponseReverbParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKFlatFrequencyResponseReverbParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var reverbDuration: Double = AKFlatFrequencyResponseReverb.defaultReverbDuration {
        didSet { setParameter(.reverbDuration, value: reverbDuration) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createFlatFrequencyResponseReverbDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let reverbDuration = AUParameterTree.createParameter(
            withIdentifier: "reverbDuration",
            name: "Reverb Duration (Seconds)",
            address: AKFlatFrequencyResponseReverbParameter.reverbDuration.rawValue,
            min: Float(AKFlatFrequencyResponseReverb.reverbDurationRange.lowerBound),
            max: Float(AKFlatFrequencyResponseReverb.reverbDurationRange.upperBound),
            unit: .seconds,
            flags: .default)
        
        setParameterTree(AUParameterTree.createTree(withChildren: [reverbDuration]))
        reverbDuration.value = Float(AKFlatFrequencyResponseReverb.defaultReverbDuration)
    }

    public override var canProcessInPlace: Bool { return true }

}
