//
//  AKWhiteNoiseAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKWhiteNoiseAudioUnit: AKGeneratorAudioUnitBase {

    func setParameter(_ address: AKWhiteNoiseParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKWhiteNoiseParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var amplitude: Double = AKWhiteNoise.defaultAmplitude {
        didSet { setParameter(.amplitude, value: amplitude) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createWhiteNoiseDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let amplitude = AUParameter(
            identifier: "amplitude",
            name: "Amplitude",
            address: AKWhiteNoiseParameter.amplitude.rawValue,
            range: AKWhiteNoise.amplitudeRange,
            unit: .generic,
            flags: .default)

        setParameterTree(AUParameterTree(children: [amplitude]))
        amplitude.value = Float(AKWhiteNoise.defaultAmplitude)
    }

    public override var canProcessInPlace: Bool { return true }

}
