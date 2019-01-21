//
//  AKCombFilterReverbAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKCombFilterReverbAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKCombFilterReverbParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKCombFilterReverbParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var reverbDuration: Double = AKCombFilterReverb.defaultReverbDuration {
        didSet { setParameter(.reverbDuration, value: reverbDuration) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createCombFilterReverbDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let reverbDuration = AUParameter(
            identifier: "reverbDuration",
            name: "Reverb Duration (Seconds)",
            address: AKCombFilterReverbParameter.reverbDuration.rawValue,
            range: AKCombFilterReverb.reverbDurationRange,
            unit: .seconds,
            flags: .default)

        setParameterTree(AUParameterTree(children: [reverbDuration]))
        reverbDuration.value = Float(AKCombFilterReverb.defaultReverbDuration)
    }

    public override var canProcessInPlace: Bool { return true }

}
